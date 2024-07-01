import argparse
import json
import pathlib
from typing import Optional

import numpy as np
import pandas as pd
from sklearn.cluster import KMeans

from flow_parsing.features import generate_raw_feature_names

try:
    from libKMCUDA import kmeans_cuda
except ImportError:
    print('libKMCUDA was not found: calling fit() for PacketQuantizer is not possible, kmcuda must be installed')

from settings import logger, BASE_DIR


def get_kmeans_mae(original, restored):
    s = np.abs(original - restored).sum()
    mae = np.abs(original - restored).mean()
    logger.info(f'MAE: {mae}, cumulative error: {s}')
    return mae


def drop_nan_packets(packet_features):
    return packet_features[~np.isnan(packet_features) & ~np.isinf(packet_features)].reshape(-1, 2)


def init_sklearn_kmeans_from_checkpoint(checkpoint_path):
    checkpoint_path = pathlib.Path(checkpoint_path)
    with open(checkpoint_path / 'clusters.json', 'rb') as jf:
        clusters = np.array(json.load(jf))

    clusters = drop_nan_packets(clusters)
    # make KMeans think it was fitted
    quantizer = KMeans(n_clusters=clusters.shape[0])
    quantizer._n_threads = 1
    quantizer.cluster_centers_ = clusters
    logger.info(f'init sklearn KMeans from checkpoint: {checkpoint_path}')
    return quantizer


class PacketScaler:
    def __init__(self, max_packet_len=1500):
        self.max_packet_len = max_packet_len

    def transform(self, packet_pairs):
        """
        :param packet_pairs: (N, 2), 0 -- packet_len, 1 -- IAT
        :return: transformed_packets (N, 2)
        """
        packet_pairs[:, 0] = packet_pairs[:, 0] / self.max_packet_len
        # avoids warning and -inf values. the scale here is in microseconds (?)
        zero_iats = np.isclose(packet_pairs[:, 1], 0.)
        packet_pairs[:, 1][zero_iats] = 0
        packet_pairs[:, 1][~zero_iats] = np.log10(packet_pairs[:, 1][~zero_iats])
        return packet_pairs

    def inverse_transform(self, packet_pairs):
        packet_pairs[:, 0] = packet_pairs[:, 0] * self.max_packet_len
        # to correctly rescale, we need to know which were initially zeros
        zero_iats = np.isclose(packet_pairs[:, 1], 0., atol=1e-3)
        packet_pairs[:, 1][zero_iats] = 0
        packet_pairs[:, 1][~zero_iats] = 10 ** packet_pairs[:, 1][~zero_iats]
        return packet_pairs


class PacketQuantizer:
    """
    You can init PacketQuantizer for transform() and inverse_transform() only after loading from checkpoint
    """

    def __init__(self,
                 n_clusters=16384,
                 flow_size=128,
                 packet_scaler=PacketScaler,
                 kmeans_clusterizer: Optional[KMeans] = None):
        self.n_clusters = n_clusters
        # hard-coded to the expected dataframe format (as in features.py)
        self.iat_columns = generate_raw_feature_names(flow_size, base_features=('iat',))
        self.packet_columns = generate_raw_feature_names(flow_size, base_features=('packet',))
        self.raw_columns = generate_raw_feature_names(flow_size)
        self.scaler = packet_scaler()
        self._cluster_centers = None
        self.kmeans = kmeans_clusterizer
        self.non_packet_value = -1

    def fit(self, raw_batch):
        """
        https://github.com/src-d/kmcuda#python-api
        due to performance reasons, uses kmcuda instead of sklearn's KMeans.
        :param raw_batch:
        :return:
        """
        # do not consider single-packet flows
        raw_batch = raw_batch[raw_batch.raw_packet1 != 0]
        # form matrix (n_packet x (packet_size, IAT))
        packet_features = raw_batch[self.raw_columns].values.reshape(-1, 2)
        # omit non_packet values
        packet_features = drop_nan_packets(packet_features)
        init_clusters = "k-means++" if self._cluster_centers is None else self._cluster_centers
        logger.info('fitting on {} packets, init clusters from data: {}'.format(packet_features.shape[0],
                                                                                isinstance(init_clusters, str)))
        packet_features = self.scaler.transform(packet_features)

        cluster_centers_, assignments = kmeans_cuda(
            samples=packet_features,
            clusters=self.n_clusters,
            tolerance=0.01,
            init=init_clusters,
            yinyang_t=0,
            metric="L2",
            average_distance=False,
            seed=1, device=0, verbosity=1
        )
        self._cluster_centers = cluster_centers_
        self._evaluate(packet_features, cluster_centers_[assignments])

    def _evaluate(self, packet_features, restored):
        n_unique_clusters = len(self._cluster_centers[~np.isnan(self._cluster_centers)]) / 2
        logger.info(f'found {n_unique_clusters} unique clusters')
        get_kmeans_mae(packet_features, restored)

    def save_checkpoint(self, save_directory):
        save_directory = pathlib.Path(save_directory)
        save_directory.mkdir(exist_ok=True)
        quantizer_path = save_directory / 'clusters.json'
        with open(quantizer_path, 'w') as qf:
            try:
                json.dump(self._cluster_centers.tolist(), qf)
            except AttributeError:
                # account for the case when saving not during training
                json.dump(self.kmeans.cluster_centers_.tolist(), qf)
        logger.info(f'saving checkpoint to {quantizer_path}')
        return quantizer_path.as_posix()

    @classmethod
    def from_checkpoint(cls, checkpoint_path, *args, **kwargs):
        kmeans = init_sklearn_kmeans_from_checkpoint(checkpoint_path)
        return cls(n_clusters=kmeans.n_clusters, kmeans_clusterizer=kmeans, *args, **kwargs)

    def transform(self, raw_packet_batch):
        """ transforms raw packet matrix of size (n_flows, packets*2)
        (where 2 is due to features - PS, IAT) to packet clusters matrix
        of size (n_flows, packets). Non-packet values in the source matrix
        MUST BE NaN, and in the cluster matrix they correspond to -1.
        """
        if self.kmeans is None:
            raise Exception('the class must be init with an sklearn KMeans instance first!')

        if isinstance(raw_packet_batch, pd.DataFrame):
            # assert correct order
            raw_packet_batch = raw_packet_batch[self.raw_columns].values

        batch_size = raw_packet_batch.shape[0]
        # reshape to form (n_samples, n_features) for PacketScaler and KMeans
        raw_packet_batch = raw_packet_batch.reshape(-1, 2)
        non_packet_mask = np.isnan(raw_packet_batch) | np.isinf(raw_packet_batch)
        # temp fill to allow for predicting
        raw_packet_batch[non_packet_mask] = 0
        clusters = self.kmeans.predict(self.scaler.transform(raw_packet_batch))
        # set non_packet clusters to NaN
        non_packet_cluster_mask = non_packet_mask.sum(axis=1).astype(bool)
        clusters[non_packet_cluster_mask] = self.non_packet_value
        # reshape back to batch form
        clusters = clusters.reshape(batch_size, -1)
        return clusters

    def inverse_transform(self, cluster_batch):
        flat_clusters = cluster_batch.flatten()
        non_packet_cluster_mask = flat_clusters == self.non_packet_value
        # assign temp cluster value
        flat_clusters[non_packet_cluster_mask] = 0
        outbound_cluster_mask = flat_clusters >= self.n_clusters
        n_outbound_clusters = outbound_cluster_mask.sum()
        if n_outbound_clusters > 0:
            logger.warning(f'found {n_outbound_clusters} outbounding cluster values')
            flat_clusters[outbound_cluster_mask] = 0
        reverted_packets = self.scaler.inverse_transform(self.kmeans.cluster_centers_[flat_clusters])
        # make NaN non-packets
        reverted_packets[non_packet_cluster_mask] = np.nan
        reverted_packets = reverted_packets.reshape(-1, cluster_batch.shape[1] * 2)
        return reverted_packets


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-s", "--source",
        help="source folder with .csv files. the recommended way is to create a folder with all the training data, that"
             "was merged and shuffled beforehand (e.g. via pandas)"
    )
    args = parser.parse_args()

    quantizer = PacketQuantizer(n_clusters=16384, flow_size=128)
    raw_csv_dir = pathlib.Path(args.source)

    flow_limit = 1_000_000
    for file_idx, csv in enumerate(raw_csv_dir.glob('*.csv')):
        logger.info(f'processing {csv}')
        reader = pd.read_csv(csv, chunksize=flow_limit, usecols=quantizer.raw_columns, dtype=np.float32)
        for batch, raw_packets in enumerate(reader):
            quantizer.fit(raw_packets)
            if batch % 10 == 0:
                quantizer.save_checkpoint(
                    BASE_DIR / f'gpt_model/trained_quantizers/quantizer_2^14_{csv.stem}_{batch}')

        quantizer.save_checkpoint(BASE_DIR / f'gpt_model/trained_quantizers/quantizer_2^14_{csv.stem}_final')


if __name__ == '__main__':
    main()
