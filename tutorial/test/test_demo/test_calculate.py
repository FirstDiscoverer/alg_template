from src.common.test import BaseTest
from tutorial.test.test_demo.calculate import Calculate


# ① 【测试文件位置规范】测试文件位置与被测试文件在同一目录下

# ② 【测试文件命名规范】test_需要测试的文件.py

# ③ 【类名命名规范】Test需要测试的类

class TestCalculate(BaseTest):

    @classmethod
    def setUpClass(cls) -> None:
        cls.calculate = Calculate()

    # ④ 【方法命名规范】test_需要测试的方法名
    def test_add(self):
        result = self.calculate.add(3, 2)
        # ⑥【assert规范】第一个为期待值，第二个为实际值
        self.assertEqual(5, result)
