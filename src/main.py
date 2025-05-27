import uvicorn

from src.config.base import Init
from src.web.common import exception
from src.web.common.constant import my_app
from src.web.controller import biz, md, ok

# 放上面，避免多个worker无法加载
exception.init_exception()
my_app.include_router(ok.router)
my_app.include_router(md.router)
my_app.include_router(biz.router)

if __name__ == '__main__':
    log_config = Init.init_log()
    uvicorn.run(app='src.web.common.constant:my_app', host="0.0.0.0", port=8080, workers=1, log_config=log_config)
