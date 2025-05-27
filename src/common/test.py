from unittest import TestCase

from src.config.base import Init


class BaseTest(TestCase):

    def setUp(self):
        super().setUp()
        Init.init_log()
