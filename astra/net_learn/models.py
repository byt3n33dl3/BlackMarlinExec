from typing import List, Optional

import logging
import torch
from pytorch_lightning import LightningModule
from torch.nn import functional as F
from torch.optim.lr_scheduler import ReduceLROnPlateau
from transformers.trainer_utils import set_seed

from evaluation_utils.classification import Reporter
from settings import RANDOM_SEED

set_seed(RANDOM_SEED)
logger = logging.getLogger(__file__)


class BaseClassifier(LightningModule):
    def __init__(self, config, class_labels: Optional[List[str]], *args, **kwargs):
        super().__init__()
        self.hparams = config
        self.class_labels = class_labels
        self.output_dim = len(class_labels)

    def forward(self, x):
        return self.net(x)

    def training_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = F.cross_entropy(y_hat, y)
        logs = {'train_loss': loss}
        return {'loss': loss, 'log': logs}

    def validation_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        return {'val_loss': F.cross_entropy(y_hat, y)}

    def validation_epoch_end(self, outputs):
        avg_loss = torch.stack([x['val_loss'] for x in outputs]).mean()
        logs = {'val_loss': avg_loss}
        return {'val_loss': avg_loss, 'log': logs}

    def test_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        predictions = y_hat.max(axis=1)[1]
        loss = F.cross_entropy(y_hat, y)
        logs = {'test_loss': loss}
        return {'test_loss': loss,
                'predictions': predictions.to('cpu'),
                'targets': y.to('cpu'),
                'log': logs}

    def test_epoch_end(self, outputs):
        avg_loss = torch.stack([x['test_loss'] for x in outputs]).mean()
        predictions = torch.cat([x['predictions'] for x in outputs]).to('cpu').numpy()
        targets = torch.cat([x['targets'] for x in outputs]).to('cpu').numpy()
        rpt = Reporter(targets, predictions, self.__class__.__name__, target_classes=self.class_labels)
        self.logger.experiment.log_image('confusion_matrix', rpt.plot_conf_matrix())

        report_file = f'report_{self.__class__.__name__}.csv'
        clf_report = rpt.clf_report(save_to=report_file)
        print(clf_report)
        self.logger.experiment.log_artifact((rpt.save_dir / report_file).as_posix())

        logs = rpt.scores()
        logs.update({'test_loss': avg_loss})
        return {'test_loss': avg_loss, 'log': logs}

    def configure_optimizers(self):
        optimizer = torch.optim.Adam(self.parameters(), lr=self.hparams.learning_rate)
        scheduler = ReduceLROnPlateau(optimizer, patience=self.hparams.es_patience // 2)
        return [optimizer], [scheduler]


class DenseClassifier(BaseClassifier):
    def __init__(self, config, class_labels, input_size, hidden_size=40, activation=torch.nn.LeakyReLU, dropout=0.1):
        super().__init__(config, class_labels)

        self.net = torch.nn.Sequential(torch.nn.Linear(input_size, hidden_size),
                                       activation(),
                                       torch.nn.Dropout(dropout),
                                       torch.nn.Linear(hidden_size, hidden_size),
                                       activation(),
                                       torch.nn.Dropout(dropout),
                                       torch.nn.Linear(hidden_size, hidden_size),
                                       activation(),
                                       torch.nn.Dropout(dropout),
                                       torch.nn.Linear(hidden_size, self.output_dim))


class BiGRUClassifier(BaseClassifier):
    def __init__(self, config, class_labels, input_size, num_layers=3, hidden_size=None, dropout=0.1, bidirectional=True):
        super().__init__(config, class_labels)

        if not hidden_size:
            hidden_size = self.output_dim

        self.gru = torch.nn.GRU(input_size,
                                hidden_size,
                                num_layers=num_layers,
                                batch_first=True,
                                dropout=dropout,
                                bidirectional=bidirectional)

        self.activation = torch.nn.LeakyReLU()
        gru_out_size = 2*hidden_size if bidirectional else hidden_size
        self.layer_norm = torch.nn.LayerNorm(gru_out_size)
        self.fc = torch.nn.Linear(gru_out_size, self.output_dim)

    def forward(self, x):
        gru_out, hidden_state = self.gru(x.unsqueeze_(2))
        out = self.activation(gru_out.max(axis=1)[0])
        out = self.layer_norm(out)
        return self.fc(out)
