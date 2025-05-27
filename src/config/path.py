from dataclasses import dataclass

from src.config.base import base_config


# 文件目录配置
@dataclass
class CommonDir:
    DATA_DIR = base_config.join_path('data')
    MODEL_DIR = base_config.join_path('model')
    OUTPUT_DIR = base_config.join_path('output')
