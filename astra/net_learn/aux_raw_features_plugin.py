import logging

import dpkt
import nfstream
import numpy as np

logger = logging.getLogger(__name__)


class AuxRawFeatures(nfstream.NFPlugin):
    @staticmethod
    def _fill_flow_stats(flow, packet, counter=0):
        flow.udps.bulk[counter] = packet.payload_size
        if packet.protocol == 6 and packet.ip_version == 4:
            decoded_packet = dpkt.ip.IP(packet.ip_packet)
            try:
                flow.udps.tcp_window[counter] = decoded_packet.data.win
                flow.udps.tcp_flag[counter] = decoded_packet.data.flags
            except AttributeError:
                logger.warning(f'unexpected packet format: {decoded_packet}')

    def on_init(self, packet, flow):
        flow.udps.bulk = np.ones(self.packet_limit) * -1
        flow.udps.tcp_window = np.zeros(self.packet_limit)
        flow.udps.tcp_flag = np.zeros(self.packet_limit)

        self._fill_flow_stats(flow, packet)

    def on_update(self, packet, flow):
        if flow.bidirectional_packets <= self.packet_limit:
            self._fill_flow_stats(flow, packet, flow.bidirectional_packets - 1)
