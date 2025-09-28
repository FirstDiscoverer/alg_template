import json
import os
from pathlib import Path
from typing import Dict, Union

import yaml
from deepmerge import always_merger
from loguru import logger

from src.config.log import LogConfig


class Env:
    """
    环境变量
    """
    PROFILE = 'PROFILE'
    PATH_LOG = 'PATH_LOG'
    CONFIG_JSON = 'CONFIG_JSON'  # 存储配置的环境变量


class ProfileConstant:
    DEV = 'dev'
    TEST = 'test'
    PRE = 'pre'
    PROD = 'prod'


class BaseConfig:
    PROFILE: str = os.getenv(Env.PROFILE, ProfileConstant.DEV)
    __PATH_BASE: Path = next(p.parent for p in Path(__file__).resolve().parents if p.name == 'src')
    PATH_LOG: Path = Path(os.getenv(Env.PATH_LOG, __PATH_BASE / 'logs'))
    PROJECT_NAME: str = __PATH_BASE.name
    __CONFIG: Dict = None
    __initialized = False

    def __new__(cls, *args, **kwargs):
        raise RuntimeError('请使用 get_config() 获取配置')

    @classmethod
    def join_path(cls, *path: Union[str, Path]) -> Path:
        return cls.__PATH_BASE.joinpath(*map(str, path))

    @classmethod
    def remove_base_dir(cls, path: Union[str, Path]) -> Path:
        return Path(path).relative_to(cls.__PATH_BASE)

    @classmethod
    def get_config(cls) -> Dict:
        # 从环境变量里读配置。原因：防止在多进程下重复加载配置文件
        if cls.__CONFIG is None:
            if os.getenv(Env.CONFIG_JSON):
                cls.__CONFIG = json.loads(os.environ[Env.CONFIG_JSON])
            else:
                raise RuntimeError('未找到环境变量 CONFIG_JSON，请先在主进程(main方法) Init.init() 初始化配置')
        return cls.__CONFIG

    @classmethod
    def __read_config(cls) -> Dict:
        profile = cls.PROFILE
        logger.info(f'注意：当前环境为 {profile}')
        base_config_path = cls.join_path('src', 'config', 'application.yaml')
        env_config_path = cls.join_path('src', 'config', f'application-{profile}.yaml')

        config = {}
        logger.debug(f'读取配置文件 start')
        for config_path in [base_config_path, env_config_path]:
            if not config_path.exists():
                raise FileNotFoundError(config_path)
            with config_path.open(encoding='utf-8') as f:
                config_part = yaml.safe_load(f)
                if config_part:
                    always_merger.merge(config, config_part)
        logger.debug(f'读取配置文件 end')
        return config

    @classmethod
    def init(cls):
        """
        主进程里调用，把配置写入环境变量
        """
        logger.debug('config初始化 start')
        if cls.__initialized:
            logger.warning('config初始化 重复')
            return
        config = cls.__read_config()
        os.environ[Env.CONFIG_JSON] = json.dumps(config, ensure_ascii=False)
        cls.__initialized = True
        logger.debug('config初始化 end')


class Init:

    @classmethod
    def init(cls, log_dir=BaseConfig.PATH_LOG, clear_old_log: bool = False):
        LogConfig.init(log_dir, clear_old_log)
        BaseConfig.init()
