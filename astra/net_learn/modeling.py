import logging
from functools import partial

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import scipy

from flow_parsing.features import inter_packet_times_from_timestamps

logger = logging.getLogger(__name__)


def flows_to_packets(flows):
    return flows[~np.isnan(flows)].reshape(-1, 2)


def convert_ipt_to_iat(flows):
    """ converts inter-packet time (IPT - timing between 2 any packets) to
        inter-arrival time (IAT - timing between 2 consecutive packets within 1 direction) """

    def ipt_to_iat(flow):
        """
        :param flow: source flow of size (packet_num, feature_num=2)
        :return:
        """
        timestamps_like = np.cumsum(flow[:, 1])
        direction_from_mask = flow[:, 0] > 0
        direction_to_mask = flow[:, 0] < 0

        iat_flow = np.full(flow.shape, np.nan)
        iat_flow[direction_from_mask, 1] = inter_packet_times_from_timestamps(timestamps_like[direction_from_mask])
        iat_flow[direction_to_mask, 1] = inter_packet_times_from_timestamps(timestamps_like[direction_to_mask])
        iat_flow[:, 0] = flow[:, 0]
        return iat_flow

    source_shape = flows.shape
    raw_packets = flows.reshape(-1, 2)  # per-packet view
    raw_packets = raw_packets.reshape(-1, source_shape[1] // 2, 2)  # (n_flows, n_packets, features)
    iat_packets = np.empty_like(raw_packets)
    for i in range(source_shape[0]):
        iat_packets[i, :, :] = ipt_to_iat(raw_packets[i])
    iat_packets = iat_packets.reshape(source_shape)
    return iat_packets


def plot_packets(packet_features, limit_packet_scale=False, save_to=None, ru_lang=False):
    if isinstance(packet_features, pd.DataFrame):
        packet_features = packet_features.values

    fig, ax = plt.subplots(figsize=(12, 7))
    plt.scatter(packet_features[:, 0], packet_features[:, 1], alpha=0.3)
    ax.set_title(f'Число кластеров: {packet_features.shape[0]}' if ru_lang else
                 f'Number of items: {packet_features.shape[0]}')
    if limit_packet_scale:
        ax.set_xlim(-1, 1)
    ax.grid(True)
    ax.set_xlabel('размер пакета, байт / 1500' if ru_lang else
                  'packet size, bytes / 1500')
    ax.set_ylabel('log10(межпакетный интервал, µs)' if ru_lang else
                  'log10(inter-packet time, µs)')
    if save_to:
        plt.savefig(save_to, dpi=300)


def packets_per_flow(flows):
    non_packet_mask = ~np.isnan(flows)
    return non_packet_mask.sum(1) / 2


def handle_estimation_exceptions(func):
    def real_decorator(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception as e:
            logger.error(f'{func.__name__}: {e}')
            return np.nan

    return real_decorator


@handle_estimation_exceptions
def estimate_pdf(samples):
    x_values = np.linspace(0, max(samples), 100)
    kde = scipy.stats.gaussian_kde(samples)(x_values)
    kde /= sum(kde)
    return kde


@handle_estimation_exceptions
def get_kl_divergence_continuous(orig_values, gen_values):
    kde_orig = estimate_pdf(orig_values)
    kde_gen = estimate_pdf(gen_values)
    return scipy.stats.entropy(kde_orig, kde_gen)


@handle_estimation_exceptions
def get_wasserstein_distance_pdf(orig_values, gen_values):
    kde_orig = estimate_pdf(orig_values)
    kde_gen = estimate_pdf(gen_values)
    return scipy.stats.wasserstein_distance(kde_orig, kde_gen)


@handle_estimation_exceptions
def get_ks_stat(orig_values, gen_values):
    ks = scipy.stats.ks_2samp(orig_values, gen_values)
    return ks.statistic


def scaled_diff(orig, gen):
    return np.abs(orig - gen) / orig


@handle_estimation_exceptions
def scaled_diff_at_percentile(orig, gen, percentile):
    o = np.percentile(orig, percentile)
    g = np.percentile(gen, percentile)
    return scaled_diff(o, g)


def packets_to_throughput(packets, resolution='1S'):
    # replace indexes with DateTime format
    df = pd.Series(
        packets[:, 0],
        index=pd.to_datetime(np.cumsum(packets[:, 1]), unit='ms')
    )
    throughput = df.resample(resolution).sum()
    return throughput.values


def evaluate_generated_traffic(src_flows: np.ndarray, gen_flows: np.ndarray) -> dict:
    logger.info('starting evaluation of flows...')
    src_packets = flows_to_packets(convert_ipt_to_iat(src_flows))
    gen_packets = flows_to_packets(convert_ipt_to_iat(gen_flows))

    client_src_mask = src_packets[:, 0] > 0
    client_gen_mask = gen_packets[:, 0] > 0

    client_src_packets = src_packets[client_src_mask]
    server_src_packets = src_packets[~client_src_mask]

    client_gen_packets = gen_packets[client_gen_mask]
    server_gen_packets = gen_packets[~client_gen_mask]

    throughput = {
        'src_avg_throughput_bytes_per_s_client': np.mean(packets_to_throughput(client_src_packets)),
        'gen_avg_throughput_bytes_per_s_client': np.mean(packets_to_throughput(client_gen_packets)),
        'src_avg_throughput_bytes_per_s_server': np.mean(packets_to_throughput(server_src_packets)),
        'gen_avg_throughput_bytes_per_s_server': np.mean(packets_to_throughput(server_gen_packets)),
    }

    metrics = {}

    for metric_name, metric_function in [
        ('KL', get_kl_divergence_continuous),
        # ('Wasserstein', get_wasserstein_distance_pdf),
        ('KS_2sample', get_ks_stat),
        ('10th_percentile', partial(scaled_diff_at_percentile, percentile=10)),
        # ('25th_percentile', partial(scaled_diff_at_percentile, percentile=25)),
        ('50th_percentile', partial(scaled_diff_at_percentile, percentile=50)),
        # ('75th_percentile', partial(scaled_diff_at_percentile, percentile=75)),
        ('90th_percentile', partial(scaled_diff_at_percentile, percentile=90))

    ]:
        metrics.update({
            metric_name + '_packets_per_flow': metric_function(packets_per_flow(src_flows), packets_per_flow(gen_flows)),
            metric_name + '_PS_client': metric_function(client_src_packets[:, 0], client_gen_packets[:, 0]),
            metric_name + '_IAT_client': metric_function(client_src_packets[:, 1], client_gen_packets[:, 1]),
            metric_name + '_PS_server': metric_function(server_src_packets[:, 0], server_gen_packets[:, 0]),
            metric_name + '_IAT_server': metric_function(server_src_packets[:, 1], server_gen_packets[:, 1]),
            metric_name + '_thrpt_client': metric_function(packets_to_throughput(client_src_packets),
                                                           packets_to_throughput(client_gen_packets)),
            f'{metric_name}_thrpt_server': metric_function(packets_to_throughput(server_src_packets),
                                                           packets_to_throughput(server_gen_packets)),
        })

    common_metrics = {
        'n_flows': min(src_flows.shape[0], gen_flows.shape[0])
    }
    return dict(**common_metrics, **metrics, **throughput)


def save_metrics(metrics: dict, save_to):
    pd.DataFrame(metrics).T.to_csv(save_to)
