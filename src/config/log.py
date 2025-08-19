import json
from pathlib import Path
from typing import Dict
from unittest import TestCase

from loguru import logger


class LogConfig:

    def __init__(self, log_dir: Path):
        self.__log_dir = Path(log_dir)

    def init_log(self):
        self.__log_dir.mkdir(parents=True, exist_ok=True)

        # 移除默认 stderr handler
        logger.remove()

        # 通用日志格式
        common_format = (
            "<green>{time:YYYY-MM-DD HH:mm:ss}</green> | "
            "<level>{level: <8}</level> | "
            "PID:<cyan>{process.id}</cyan> TID:<cyan>{thread.id}</cyan> | "
            "<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - "
            "<level>{message}</level>"
        )

        # 控制台输出
        logger.add(
            sink=lambda msg: print(msg, end=""),
            format=common_format,
            level="DEBUG",
            enqueue=True,  # ✅ 多线程+多进程安全
        )

        # 文件日志配置（级别 -> retention 天数）
        file_configs = {
            "DEBUG": 1,
            "INFO": 7,
            "WARNING": 7,
            "ERROR": 14,
        }

        # 自动添加文件日志，多进程写同一个文件安全
        for level, retention_days in file_configs.items():
            logger.add(
                self.__log_dir / f"{level.lower()}.log",
                rotation="1 day",
                retention=retention_days,
                encoding="utf-8",
                level=level,
                format=common_format,
                enqueue=True,  # ✅ 多进程安全
            )

        # dot 专用日志，只输出 message
        logger.add(
            self.__log_dir / "dot.log",
            rotation="1 day",
            retention=7,
            encoding="utf-8",
            level="INFO",
            format="{message}",
            filter=lambda record: record["extra"].get("name") == "dot",  # ✅ 只写入绑定 name="dot" 的日志
            enqueue=True,  # ✅ 多进程安全
        )
        logger.info("日志初始化完成")


class LogUtils:

    @staticmethod
    def dot_log(data: Dict):
        logger.bind(name="dot").info(json.dumps(data, ensure_ascii=False))


class LogTest(TestCase):

    def setUp(self):
        log_dir = Path(__file__).resolve().parent.parent.parent / 'logs'
        log_config = LogConfig(log_dir)
        log_config.init_log()

    def test_log(self):
        logger.debug('debug')
        logger.info('info')
        logger.warning('warning')
        logger.error('error')

    def test_dot_log(self):
        data = {'name': '张三'}
        LogUtils.dot_log(data)
