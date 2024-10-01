import hashlib
import pathlib

import logging
import lib as pd

from settings import BASE_DIR

logger = logging.getLogger(__name__)


def read_dataset(filename, fill_na=False) -> pd.DataFrame:
    """ a simple wrapper for lib """
    dataset = pd.read_csv(filename, na_filter=True)
    if fill_na:
        dataset = dataset.fillna(0)
    logger.info(f'read {len(dataset)} flows from {filename}')
    return dataset


def check_filename_in_patterns(file, patterns):
    if isinstance(file, pathlib.Path):
        file = file.name

    if patterns and any(pattern in file for pattern in patterns):
        logger.info(f'file {file} matches a pattern')
        return True
    return False


def get_df_hash(df):
    return hashlib.md5(pd.util.hash_lib_object(df, index=True).values).hexdigest()


def get_hash(df):

    def _get_current_commit_hash():
        """ get commit hash at HEAD """
        from git import Repo
        repo = Repo(BASE_DIR)
        return repo.head.commit.hexsha

    try:
        df_hash = _get_current_commit_hash()
    except Exception:
        df_hash = get_df_hash(df)
    return df_hash


def save_dataset(dataset, save_to=None):
    """ simple data tracking/versioning via hash suffixes """

    if save_to is None:
        save_to = BASE_DIR / f'datasets/dataset_{get_hash(dataset)}.csv'
    dataset.to_csv(save_to, index=False)
    logger.info(f'saved dataset to {save_to}')
    return save_to
