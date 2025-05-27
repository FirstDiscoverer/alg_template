from datetime import datetime

import tensorflow as tf
from tqdm import tqdm

config = tf.ConfigProto()
config.gpu_options.allow_growth = True
sess = tf.Session(config=config)

print("=" * 10 + f'【gpu】: {tf.test.is_gpu_available()}' + "=" * 10)

device_name = "gpu"
shape = (5000, 5000)
if device_name == "gpu":
    device_name = "/gpu:0"
else:
    device_name = "/cpu:0"

with tf.device(device_name):
    random_matrix = tf.random_uniform(shape=shape, minval=0, maxval=1)
    dot_operation = tf.matmul(random_matrix, tf.transpose(random_matrix))
    sum_operation = tf.reduce_sum(dot_operation)

startTime = datetime.now()
with tf.Session(config=tf.ConfigProto(log_device_placement=True)) as session:
    for i in tqdm(range(300)):
        result = session.run(sum_operation)

print("=" * 10 + f'【time】: {datetime.now() - startTime}"' + "=" * 10)
