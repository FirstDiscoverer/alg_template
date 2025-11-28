import uvicorn

from src.config.base import BaseConfig, Init, ProfileConstant
from src.web.common.init_app import init_app


def create_app():
    # 1. 先初始化配置
    Init.init()
    my_app = init_app()

    # 2. 再 import 依赖配置的模块；挂载路由
    from src.web.controller import ok, md, biz

    my_app.include_router(ok.router)
    my_app.include_router(md.router)
    my_app.include_router(biz.router)

    return my_app


if __name__ == '__main__':
    dev_flag = BaseConfig.PROFILE == ProfileConstant.DEV
    reload = dev_flag  # Pycharm DeBUG运行时，reload需要为True，否则可能会错误
    works = 1 if dev_flag else 2
    uvicorn.run(app='src.main:create_app', host="0.0.0.0", port=8080,
                factory=True, reload=reload, workers=works)
