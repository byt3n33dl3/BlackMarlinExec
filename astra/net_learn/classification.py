import pathlib
from typing import Optional

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.metrics import confusion_matrix, accuracy_score, f1_score, classification_report

from settings import REPORT_DIR


class Reporter:
    def __init__(self, true, predicted,
                 classifier_name: str,
                 target_classes: Optional[list] = None,
                 report_dir=REPORT_DIR):
        self.true = true
        self.predicted = predicted
        self.target_classes = target_classes if len(target_classes) > 0 else list(range(max(true) + 1))
        self.classifier_name = classifier_name
        self.save_dir = pathlib.Path(report_dir)
        self.save_dir.mkdir(exist_ok=True)

    def scores(self):
        return {
            'Accuracy': accuracy_score(self.true, self.predicted),
            'F1 macro': f1_score(self.true, self.predicted, average='macro'),
            'F1 weighted': f1_score(self.true, self.predicted, average='weighted')
        }

    def clf_report(self, as_dict=False, save_to=None):
        def to_df(report):
            return pd.DataFrame(report).T

        report = classification_report(self.true, self.predicted,
                                       target_names=self.target_classes,
                                       digits=3,
                                       output_dict=True)

        if save_to is not None:
            to_df(report).to_csv(self.save_dir / save_to, index=True)

        if as_dict:
            return report
        return to_df(report)

    def conf_matrix(self, normalize=None):
        return pd.DataFrame(confusion_matrix(self.true, self.predicted, normalize=normalize),
                            columns=self.target_classes,
                            index=self.target_classes)

    def plot_conf_matrix(self, normalize=None) -> plt.figure:

        cm = self.conf_matrix(normalize).values
        classes = self.target_classes
        fig_size = int(len(classes) * 0.7)
        fig, ax = plt.subplots(ncols=1, nrows=1, figsize=(fig_size, fig_size))

        im = ax.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
        ax.set_title('CM of {} classifier'.format(self.classifier_name))
        fig.colorbar(im, aspect=30, shrink=0.8, ax=ax)

        tick_marks = np.arange(len(classes))
        ax.set_xticks(tick_marks)
        ax.set_xticklabels(list(classes))
        plt.setp(ax.get_xticklabels(), rotation=45)
        ax.set_yticks(tick_marks)
        ax.set_yticklabels(list(classes))

        fmt = '.2f' if normalize else 'd'
        thresh = cm.max() / 2.
        for i in range(cm.shape[0]):
            for j in range(cm.shape[1]):
                ax.text(j, i, format(cm[i, j], fmt),
                        horizontalalignment="center",
                        color="white" if cm[i, j] > thresh else "black")

        ax.set_ylabel('True label')
        ax.set_xlabel('Predicted label')
        # fig.tight_layout()
        plt.show()
        return fig
