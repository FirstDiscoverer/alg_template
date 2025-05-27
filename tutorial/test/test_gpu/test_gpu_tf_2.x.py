import time

import tensorflow as tf
from tqdm import tqdm

print(tf.test.is_built_with_cuda())

x = tf.random.normal([4000, 5000])
y = tf.random.normal([5000, 6000])
s = time.time()
for _ in tqdm(range(1000)):
    z = tf.linalg.matmul(x, y)
e = time.time()

print("=" * 10 + f'【time】: {e - s}' + "=" * 10)
