import os
import time
from multiprocessing import cpu_count

import torch
from tqdm import tqdm

# [GPU性能的简单测试脚本（pytorch版）](https://blog.csdn.net/qq_41129489/article/details/126596108)


# [限制或增加pytorch的线程个数！指定核数或者满核运行Pytorch！！！](https://blog.csdn.net/lei_qi/article/details/115358703)
cpu_num = cpu_count()  # 自动获取最大核心数目
print(f'cpu_num: {cpu_num}')
os.environ['OMP_NUM_THREADS'] = str(cpu_num)
os.environ['OPENBLAS_NUM_THREADS'] = str(cpu_num)
os.environ['MKL_NUM_THREADS'] = str(cpu_num)
os.environ['VECLIB_MAXIMUM_THREADS'] = str(cpu_num)
os.environ['NUMEXPR_NUM_THREADS'] = str(cpu_num)
torch.set_num_threads(cpu_num)

loop = 100000000000000000

# 测试cpu计算耗时
A = torch.ones(5000, 5000)
B = torch.ones(5000, 5000)
startTime1 = time.time()
for i in tqdm(range(loop), desc='CPU'):
    C = torch.matmul(A, B)
endTime1 = time.time()
print('cpu计算总时长:', round((endTime1 - startTime1) * 1000, 2), 'ms')
