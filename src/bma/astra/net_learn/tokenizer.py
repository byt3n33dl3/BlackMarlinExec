import collections
import json
import pathlib
from functools import partial
from typing import Optional, Union

import numpy as np
import pandas as pd
import torch
from transformers import PreTrainedTokenizerBase
from transformers.tokenization_utils_base import TensorType, BatchEncoding

from settings import logger
from .quantizer import PacketQuantizer


class PacketTokenizer(PreTrainedTokenizerBase):
    max_model_input_sizes = 128
    model_input_names = ["attention_mask"]

    def __init__(self,
                 packet_quantizer: PacketQuantizer,
                 unk_token="[UNK]",
                 bos_token="[BOF]",
                 eos_token="[EOF]",
                 pad_token="[PAD]",
                 **kwargs
                 ):
        super().__init__(
            unk_token=unk_token,
            bos_token=bos_token,
            eos_token=eos_token,
            pad_token=pad_token,
            **kwargs,
        )
        self.packet_quantizer = packet_quantizer
        self.cluster_num = packet_quantizer.n_clusters
        # special token ids have indexes larger than all packet clusters (which start at 0)
        ids_to_tokens = kwargs.get('ids_to_tokens')
        if ids_to_tokens:
            self.ids_to_tokens = ids_to_tokens
        else:
            self.ids_to_tokens = collections.OrderedDict([(ids + self.cluster_num, tok)
                                                          for ids, tok in enumerate(self.all_special_tokens)])

        self.tokens_to_ids = {v: k for k, v in self.ids_to_tokens.items()}
        logger.info('initialized PacketTokenizer')

    def add_class_tokens(self, class_names: list):
        classes_to_add = set(class_names) - set(self.tokens_to_ids.keys())

        ids_to_classes = collections.OrderedDict([(ids + len(self), tok) for ids, tok in enumerate(classes_to_add)])
        classes_to_ids = {v: k for k, v in ids_to_classes.items()}

        self.ids_to_tokens.update(ids_to_classes)
        self.tokens_to_ids.update(classes_to_ids)

    @classmethod
    def from_pretrained(cls, pretrained_model_name_or_path, flow_size=None):
        path_dir = pathlib.Path(pretrained_model_name_or_path)
        flow_size = cls.max_model_input_sizes if flow_size is None else flow_size

        token_map_file = path_dir / 'ids_to_tokens.json'
        if token_map_file.is_file():
            with open(token_map_file, 'r') as jf:
                ids_to_tokens = json.load(jf)
            ids_to_tokens = {int(k): v for k, v in ids_to_tokens.items()}
            logger.info('loaded special tokens map from "ids_to_tokens.json"')
        else:
            ids_to_tokens = {}
            logger.warning('special tokens map "ids_to_tokens.json" was not found, will attempt to recreate one')

        quantizer = PacketQuantizer.from_checkpoint(path_dir, flow_size=flow_size)
        return cls(
            packet_quantizer=quantizer,
            ids_to_tokens=ids_to_tokens,
        )

    def save_pretrained(self, save_directory):
        save_directory = pathlib.Path(save_directory)
        with open(save_directory / 'ids_to_tokens.json', 'w') as jf:
            json.dump(self.ids_to_tokens, jf)

        self.packet_quantizer.save_checkpoint(save_directory)

    def convert_ids_to_tokens(self, index):
        if isinstance(index, int):
            # exception indicates the bug
            return self.ids_to_tokens[index]
        else:
            raise NotImplementedError

    def convert_tokens_to_ids(self, tokens):
        if isinstance(tokens, str):
            return self.tokens_to_ids[tokens]
        else:
            raise NotImplementedError

    def _pad_flow(self, flow: np.ndarray) -> np.ndarray:
        non_packets_mask = flow == self.packet_quantizer.non_packet_value
        flow[non_packets_mask] = self.pad_token_id
        return flow

    def _expand_with_special_tokens(self, flow: np.ndarray, first_token) -> np.ndarray:
        # truncate to account for the tokens
        flow = flow[:self.max_model_input_sizes - 2]
        flow = np.insert(flow, 0, first_token)
        non_packets_mask = flow == self.packet_quantizer.non_packet_value
        flow[non_packets_mask] = self.pad_token_id
        # we either pick index of the first True value or append
        end_of_flow = non_packets_mask.argmax() if non_packets_mask.any() else len(flow)
        flow = np.insert(flow, end_of_flow, self.eos_token_id)
        return flow

    def batch_encode_packets(
            self,
            flows: Union[pd.DataFrame, np.ndarray],
            target_class: Optional[str] = None,
            add_special_tokens: bool = True,
            return_tensors: Optional[Union[str, TensorType]] = TensorType.PYTORCH,
            return_attention_mask: Optional[bool] = True,
    ) -> BatchEncoding:

        if isinstance(flows, pd.DataFrame):
            flows = flows.values

        if flows.shape[1] // 2 != self.max_model_input_sizes:
            logger.debug(f'input number of features ({flows.shape[1] // 2}) does not match '
                         f'max_model_input_sizes ({self.max_model_input_sizes})')
        clusters = self.packet_quantizer.transform(flows)

        if add_special_tokens:
            first_token = self.convert_tokens_to_ids(target_class) if target_class is not None else self.bos_token_id
            expander = partial(self._expand_with_special_tokens, first_token=first_token)
            clusters = np.apply_along_axis(expander, axis=1, arr=clusters)
        else:
            clusters = np.apply_along_axis(self._pad_flow, axis=1, arr=clusters)

        result = {'input_ids': clusters.astype(np.int64)}

        if return_attention_mask:
            token_mask = (clusters != self.pad_token_id).astype(np.int64)
            result.update({'attention_mask': token_mask})

        return BatchEncoding(result, tensor_type=TensorType(return_tensors), prepend_batch_axis=False)

    def _remove_special_tokens(self, flow):
        # rm first token
        flow = flow[1:]
        try:
            flow_end_idx = np.where(flow == self.eos_token_id)[0][0]
        except IndexError:
            flow_end_idx = flow.shape[0] - 1
            logger.warning('could not find EOS token, removing the last one')

        if flow_end_idx == flow.shape[0] - 1:
            flow = flow[:-1]
        else:
            flow = flow[:-1]
            # replace pad token with quantizer's non packet value for consistency
            flow[flow_end_idx:] = self.packet_quantizer.non_packet_value
        return flow

    def batch_decode_packets(self, tokenized_flows) -> np.ndarray:
        if isinstance(tokenized_flows, torch.Tensor):
            tokenized_flows = tokenized_flows.numpy()
        clusters_only = np.apply_along_axis(self._remove_special_tokens, axis=1, arr=tokenized_flows)
        packet_features = self.packet_quantizer.inverse_transform(clusters_only)
        return packet_features

    def __len__(self):
        return self.cluster_num + len(self.tokens_to_ids)

    @property
    def max_len(self):
        return self.max_model_input_sizes
