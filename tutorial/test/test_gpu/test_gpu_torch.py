import time

import torch
from tqdm import tqdm

# [GPU性能的简单测试脚本（pytorch版）](https://blog.csdn.net/qq_41129489/article/details/126596108)

loop = 100000000000000000

# 测试gpu计算耗时
A = torch.ones(5000, 5000).to('cuda')
B = torch.ones(5000, 5000).to('cuda')
startTime2 = time.time()
for i in tqdm(range(loop), desc='GPU'):
    C = torch.matmul(A, B)
endTime2 = time.time()
print('gpu计算总时长:', round((endTime2 - startTime2) * 1000, 2), 'ms')
