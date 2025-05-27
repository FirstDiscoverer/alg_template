import json
import logging
import logging.config as logging_config
import threading
from pathlib import Path
from typing import Dict, Union
from unittest import TestCase


class LogConfig:
    _instance = None
    _lock = threading.Lock()

    def __new__(cls, *args, **kwargs):
        if not cls._instance:
            with cls._lock:
                if not cls._instance:
                    cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self, log_dir: Union[str, Path]):
        super().__init__()
        self.__log_dir = Path(log_dir)

    def __get_file_handler_config(self, level: str, filename: str = None,
                                  formatter: str = 'format_common', backup_count: int = 7) -> dict:
        if not filename:
            filename = f"{level.lower()}"
        return {
            'level': level,
            'class': 'logging.handlers.TimedRotatingFileHandler',
            'filename': str(self.__log_dir / f"{filename}.log"),
            'when': 'D',
            'interval': 1,
            'backupCount': backup_count,
            'formatter': formatter,
            'encoding': 'utf-8',
        }

    def __get_log_config(self) -> dict:
        log_config = {
            'version': 1,
            'disable_existing_loggers': False,
            'formatters': {
                'format_common': {
                    # 参数介绍https://juejin.im/post/5bc2bd3a5188255c94465d31
                    'format': '%(asctime)s - %(name)s - %(filename)s:%(funcName)s:%(lineno)d - %(levelname)s - %(message)s',
                },
                'format_dot': {
                    'format': '%(message)s',
                },
            },
            'handlers': {
                'console': {
                    'level': 'DEBUG',
                    'class': "logging.StreamHandler",
                    'formatter': 'format_common',
                },
                'file_debug': self.__get_file_handler_config(level='DEBUG', backup_count=1),
                'file_info': self.__get_file_handler_config(level='INFO', ),
                'file_warn': self.__get_file_handler_config(level='WARN', ),
                'file_error': self.__get_file_handler_config(level='ERROR', backup_count=14),
                'file_dot': self.__get_file_handler_config(level='INFO', filename='dot', formatter='format_dot',
                                                           backup_count=7),
            },
            'loggers': {
                'dot': {
                    'level': 'INFO',
                    'handlers': ['file_dot'],
                    'propagate': True,
                }
            },
            'root': {
                'level': 'DEBUG',
                'handlers': ['console', 'file_debug', 'file_info', 'file_warn', 'file_error'],
                'propagate': True,
            }
        }

        return log_config

    def init_log(self) -> dict:
        log_dir = self.__log_dir
        log_dir.mkdir(parents=True, exist_ok=True)

        log_config = self.__get_log_config()
        logging_config.dictConfig(log_config)
        return log_config


class LogUtils:

    @staticmethod
    def dot_log(data: Dict):
        dot_log = logging.getLogger("dot")
        dot_log.info(json.dumps(data, ensure_ascii=False))


class LogTest(TestCase):

    def setUp(self):
        log_dir = Path(__file__).resolve().parent.parent.parent / 'logs'
        log_config = LogConfig(log_dir)
        log_config.init_log()

    def test_log(self):
        logging.debug('debug')
        logging.info('info')
        logging.warning('warning')
        logging.error('error')

    def test_dot_log(self):
        data = {'name': '张三'}
        LogUtils.dot_log(data)
