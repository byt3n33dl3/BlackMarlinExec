import functools
import logging
from typing import Tuple, Union, Optional

import numpy as np
from nfstream.flow import NFlow

logger = logging.getLogger(__name__)


FEATURE_FUNCTIONS = {
    '0': lambda feature_slice: _safe_vector_getter(feature_slice, 0),
    '1': lambda feature_slice: _safe_vector_getter(feature_slice, 1),
    '_max': np.max,
    '_min': np.min,
    '_avg': np.mean,
    '_median': np.median,
    '_25q': lambda feature_slice: np.percentile(feature_slice, 25),
    '_75q': lambda feature_slice: np.percentile(feature_slice, 75),
    '_sum': np.sum,
    # counting non-empty bulks (packets with payload)
    '_number': lambda feature_slice: feature_slice[feature_slice > 0].shape[0]
}

# These are not complete subsets of handcrafted features
CONTINUOUS_NAMES = tuple(base + feature for feature in FEATURE_FUNCTIONS.keys() for base in ['bulk', 'packet'])
CONTINUOUS_NAMES += ('tcp_window_avg', )

CATEGORICAL_NAMES = (
    'found_tcp_flags',
)

FEATURE_NAMES = CONTINUOUS_NAMES + CATEGORICAL_NAMES


class FEATURE_PREFIX:
    client = 'client_'
    server = 'server_'


@functools.lru_cache(maxsize=2)
def create_empty_features(prefix: str, feature_list=FEATURE_NAMES) -> dict:
    return {prefix + feature: 0. for feature in feature_list}


def _safe_vector_getter(vector, indexer) -> Union[int, float]:
    try:
        return vector[indexer]
    except IndexError:
        return np.nan


def calc_parameter_stats(feature_slice, prefix, feature_name) -> dict:
    return {prefix + feature_name + feature: func(feature_slice) for feature, func in FEATURE_FUNCTIONS.items()}


def inter_packet_times_from_timestamps(timestamps):
    if len(timestamps) == 0:
        return timestamps
    next_timestamps = np.roll(timestamps, 1)
    ipt = timestamps - next_timestamps
    ipt[0] = 0
    return ipt


def generate_raw_feature_names(flow_size, base_features: Tuple[str] = ('packet', 'iat')) -> list:
    return [f'raw_{feature}{index}'
            for index in range(flow_size)
            for feature in base_features]


def calc_raw_features(flow: NFlow) -> dict:
    """ selects PS and IPT features  """
    packet_limit = len(flow.splt_ps)
    features = dict.fromkeys(generate_raw_feature_names(packet_limit))
    for index in range(packet_limit):
        ps = flow.splt_ps[index]
        ipt = flow.splt_piat_ms[index]

        if flow.splt_direction[index] == 1:
            ps = flow.splt_ps[index] * -1
        elif flow.splt_direction[index] == -1:
            ps = np.nan
            ipt = np.nan

        features['raw_packet' + str(index)] = ps
        features['raw_iat' + str(index)] = ipt

    return features


def _calc_unidirectional_flow_features(flow: NFlow, direction_idxs, prefix='', features: Optional[list] = None) -> dict:
    # this asserts using of the listed features
    if features is None:
        features = create_empty_features(prefix)

    features.update(calc_parameter_stats(np.array(flow.splt_ps)[direction_idxs], prefix, 'packet'))

    features[prefix + 'found_tcp_flags'] = sorted(set(flow.udps.tcp_flag[direction_idxs]))
    features[prefix + 'tcp_window_avg'] = np.mean(flow.udps.tcp_window[direction_idxs])
    features.update(calc_parameter_stats(flow.udps.bulk[direction_idxs], prefix, 'bulk'))

    return features


def calc_stat_features(flow: NFlow) -> dict:
    """ estimates derivative discriminative features for flow classification from:
        packet size, payload size, TCP window, TCP flag
    """
    direction = np.array(flow.splt_direction)
    client_idxs = direction == 0
    server_idxs = direction == 1

    if client_idxs.sum() > 0:
        client_features = _calc_unidirectional_flow_features(flow, client_idxs, prefix=FEATURE_PREFIX.client)
    else:
        client_features = create_empty_features(prefix=FEATURE_PREFIX.client)

    if server_idxs.sum() > 0:
        server_features = _calc_unidirectional_flow_features(flow, server_idxs, prefix=FEATURE_PREFIX.server)
    else:
        server_features = create_empty_features(prefix=FEATURE_PREFIX.server)

    total_features = dict(**client_features, **server_features)
    return total_features
