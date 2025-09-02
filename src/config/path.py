from dataclasses import dataclass

from src.config.base import BaseConfig


# 文件目录配置
@dataclass
class CommonDir:
    DATA_DIR = BaseConfig.join_path('data')
    MODEL_DIR = BaseConfig.join_path('model')
    OUTPUT_DIR = BaseConfig.join_path('output')
