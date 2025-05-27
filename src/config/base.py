import configparser
import logging
import os
from pathlib import Path
from typing import Dict, Union


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
    __PATH_BASE: Path = Path(__file__).resolve().parent.parent.parent
    PATH_LOG: Path = Path(os.getenv(Env.PATH_LOG, __PATH_BASE / 'logs'))
    PROJECT_NAME: str = __PATH_BASE.name
    __CONFIG: configparser.ConfigParser = None

    @classmethod
    def join_path(cls, *path: Union[str, Path]) -> Path:
        return cls.__PATH_BASE.joinpath(*map(str, path))

    @classmethod
    def get_config(cls, return_dict: bool = False) -> Union[configparser.ConfigParser, Dict]:
        if cls.__CONFIG is None:
            cls.__CONFIG = cls.__read_config()
        return cls.__CONFIG if not return_dict else cls.__CONFIG.__dict__['_sections'].copy()

    def __getitem__(self, key: str) -> configparser.SectionProxy:
        return self.get_config()[key]

    @classmethod
    def __read_config(cls) -> configparser.ConfigParser:
        profile = cls.PROFILE
        logging.warning(f'注意：当前环境为 {profile}')
        base_config_path = cls.join_path('src', 'config', 'application.ini')
        env_config_path = cls.join_path('src', 'config', f'application-{profile}.ini')
        config = configparser.ConfigParser()
        config.read([base_config_path, env_config_path], encoding='utf8')
        # config_dict = config.__dict__['_sections'].copy()
        return config


base_config = BaseConfig()


class Init:

    @classmethod
    def init(cls):
        # 日志初始化
        cls.init_log()

    @classmethod
    def init_log(cls) -> dict:
        from src.config.log import LogConfig
        log_dir = BaseConfig.PATH_LOG
        config = LogConfig(log_dir)
        log_config = config.init_log()
        return log_config
