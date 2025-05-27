# 以下为历史代码，仅供参考

# @staticmethod
# def init_gpu():
#     platform_info = platform.platform(True)
#     plaidml_packages = [p for p in pkg_resources.working_set if 'plaidml' == p.key]
#     msg = 'use 【%s】 OS: %s, %s: %s'
#
#     if 'macOS' in platform_info:
#         if len(plaidml_packages) == 1:
#             os.environ["KERAS_BACKEND"] = "plaidml.keras.backend"
#             logging.info(msg % ('GPU', platform_info, 'PlaidMl', plaidml_packages[0].version))
#         else:
#             logging.info(msg % ('CPU', platform_info, 'PlaidMl', 'null'))
#     else:
#         os.environ["CUDA_VISIBLE_DEVICES"] = Constant.CUDA_VISIBLE_DEVICES
#
#         import keras.backend.tensorflow_backend as ktf
#         import tensorflow as tf
#
#         tf_version = tf.__version__
#         if re.match('1.*', tf_version):
#             config = tf.ConfigProto()
#             config.gpu_options.allow_growth = True  # 自适应分配
#             session = tf.Session(config=config)
#             ktf.set_session(session)
#         elif re.match('2.*', tf_version):
#             gpus = tf.config.experimental.list_physical_devices(device_type='GPU')
#             for gpu in gpus:
#                 tf.config.experimental.set_memory_growth(gpu, True)
#         logging.info(msg % ('CPU', platform_info, 'CUDA', 'unKnow'))
