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
    __PATH_BASE: Path = next(p.parent for p in Path(__file__).resolve().parents if p.name == 'src')
    PROJECT_NAME: str = __PATH_BASE.name
    __CONFIG: Dict = None
    __initialized_pid = None  # 记录当前进程 PID

    def __new__(cls, *args, **kwargs):
        raise RuntimeError('请使用 get_config() 获取配置')

    @staticmethod
    def profile() -> str:
        return os.getenv(Env.PROFILE, ProfileConstant.DEV)

    @classmethod
    def log_dir(cls) -> Path:
        return Path(os.getenv(Env.PATH_LOG, cls.__PATH_BASE / 'logs'))

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
        profile = cls.profile()
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
        current_pid = os.getpid()
        # 1. 同一进程重复调用，直接拦截
        if cls.__initialized_pid == current_pid:
            logger.warning(f'config初始化 重复 [PID: {current_pid}]')
            return

        # 2. 如果环境变量已有配置（说明主进程已初始化过），子进程直接标记并返回，不做任何多余操作
        if os.getenv(Env.CONFIG_JSON):
            cls.__initialized_pid = current_pid
            return

        # 3. 只有主进程首次调用时执行：读取 YAML 并写入环境变量与内存
        logger.debug('config初始化 start')
        config = cls.__read_config()
        cls.__CONFIG = config
        os.environ[Env.CONFIG_JSON] = json.dumps(config, ensure_ascii=False)

        cls.__initialized_pid = current_pid
        logger.debug('config初始化 end')


class Init:

    @classmethod
    def init(cls, log_dir: Path = None, clear_old_log: bool = False):
        if log_dir is None:
            log_dir = BaseConfig.log_dir()
        LogConfig.init(log_dir, clear_old_log)
        BaseConfig.init()
