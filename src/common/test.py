from unittest import TestCase

from src.config.base import Init

Init.init_log()


class BaseTest(TestCase):
    # 会在上面初始化日志
    pass
