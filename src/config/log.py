import json
import os
import shutil
from pathlib import Path
from typing import Dict, Union
from unittest import TestCase

from loguru import logger


class LogConfig:
    __initialized_pid = None  # 记录当前进程空间内初始化的 PID
    __has_ever_initialized = False  # 标记当前内存链中是否曾被初始化过

    def __new__(cls, *args, **kwargs):
        raise RuntimeError('请使用 init() 初始化')

    @classmethod
    def init(cls, log_dir: Union[Path, str], clear_old_log: bool = False):
        current_pid = os.getpid()
        logger.debug('loguru初始化 start')

        # 1. 当前进程已经初始化过，重复拦截
        if cls.__initialized_pid == current_pid:
            logger.warning(f'loguru初始化 重复 [PID: {current_pid}]')
            return

        log_dir = Path(log_dir)
        # 2. 清理日志逻辑：只有【最顶层主进程（首次初始化）】且 clear_old_log=True 时才清理
        # 子进程由于继承了父进程 __has_ever_initialized = True 的内存快照，必定为 False，绝对不会误删
        if clear_old_log and not cls.__has_ever_initialized:
            logger.info(f"清除旧日志: {log_dir}")
            shutil.rmtree(log_dir, ignore_errors=True)

        log_dir.mkdir(parents=True, exist_ok=True)

        logger.remove()  # 3. 移除当前进程继承的 Handler，重新配置

        # 通用日志格式
        common_format = (
            '<green>{time:YYYY-MM-DD HH:mm:ss.SSS}</green> | '
            '<level>{level: <8}</level> | '
            'PID:<cyan>{process.id}</cyan> TID:<cyan>{thread.id}</cyan> | '
            '<cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - '
            '<level>{message}</level>'
        )

        # 控制台输出
        logger.add(
            sink=lambda msg: print(msg, end=''),
            format=common_format,
            level='DEBUG',
            enqueue=True,  # ✅ 多线程+多进程安全
            colorize=True,
        )

        # 文件日志配置（级别 -> retention 天数）
        file_configs = {
            'DEBUG': 1,
            'INFO': 7,
            'WARNING': 7,
            'ERROR': 14,
        }

        # 自动添加文件日志，多进程写同一个文件安全
        for level, retention_days in file_configs.items():
            logger.add(
                log_dir / f'{level.lower()}.log',
                rotation='1 day',
                retention=retention_days,
                encoding='utf-8',
                level=level,
                format=common_format,
                filter=lambda record: record['extra'].get('name') != 'dot',
                enqueue=True,  # ✅ 多进程安全
                colorize=True,
            )

        # dot 专用日志，只输出 message
        logger.add(
            log_dir / 'dot.log',
            rotation='1 day',
            retention=7,
            encoding='utf-8',
            level='INFO',
            format='{message}',
            filter=lambda record: record['extra'].get('name') == 'dot',  # ✅ 只写入绑定 name='dot' 的日志
            enqueue=True,  # ✅ 多进程安全
        )

        # 4. 更新内存状态
        cls.__initialized_pid = current_pid
        cls.__has_ever_initialized = True  # 标记已初始化过（子进程会继承此 True 标识）
        logger.debug(f'loguru初始化 end [PID: {current_pid}]')


class LogUtils:

    @staticmethod
    def dot_log(data: Dict):
        logger.bind(name='dot').info(json.dumps(data, ensure_ascii=False))


class LogTest(TestCase):

    def setUp(self):
        log_dir = next(p.parent for p in Path(__file__).resolve().parents if p.name == 'src') / 'logs'
        LogConfig.init(log_dir)

    def test_log(self):
        logger.debug('debug')
        logger.info('info')
        logger.warning('warning')
        logger.error('error')

    def test_dot_log(self):
        data = {'name': '张三'}
        LogUtils.dot_log(data)
