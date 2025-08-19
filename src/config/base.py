import os
from pathlib import Path
from typing import Dict, Union

import yaml
from deepmerge import always_merger
from loguru import logger


class Env:
    """
    环境变量
    """
    PROFILE = 'PROFILE'
    PATH_LOG = 'PATH_LOG'


class ProfileConstant:
    DEV = 'dev'
    TEST = 'test'
    PRE = 'pre'
    PROD = 'prod'


class BaseConfig:
    # 常量
    PROFILE: str = os.getenv(Env.PROFILE, ProfileConstant.DEV)
    __PATH_BASE: Path = next(p.parent for p in Path(__file__).resolve().parents if p.name == 'src')
    PATH_LOG: Path = Path(os.getenv(Env.PATH_LOG, __PATH_BASE / 'logs'))
    PROJECT_NAME: str = __PATH_BASE.name
    __CONFIG: Dict = None

    @classmethod
    def join_path(cls, *path: Union[str, Path]) -> Path:
        return cls.__PATH_BASE.joinpath(*map(str, path))

    @classmethod
    def get_config(cls) -> Dict:
        if cls.__CONFIG is None:
            cls.__CONFIG = cls.__read_config()
        return cls.__CONFIG

    def __getitem__(self, key: str):
        return self.get_config()[key]

    @classmethod
    def __read_config(cls) -> Dict:
        profile = cls.PROFILE
        logger.info(f'注意：当前环境为 {profile}')
        base_config_path = cls.join_path('src', 'config', 'application.yaml')
        env_config_path = cls.join_path('src', 'config', f'application-{profile}.yaml')

        config = {}
        for config_path in [base_config_path, env_config_path]:
            if not config_path.exists():
                raise FileNotFoundError(config_path)
            with config_path.open(encoding='utf-8') as f:
                config_part = yaml.safe_load(f)
                if config_part:
                    always_merger.merge(config, config_part)

        return config


base_config = BaseConfig()


class Init:

    @classmethod
    def init(cls):
        cls.init_log()

    @classmethod
    def init_log(cls):
        from src.config.log import LogConfig
        log_dir = BaseConfig.PATH_LOG
        config = LogConfig(log_dir)
        log_config = config.init_log()
        return log_config
