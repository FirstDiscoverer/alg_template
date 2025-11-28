import traceback

from fastapi import FastAPI, Request
from fastapi.middleware.gzip import GZipMiddleware
from loguru import logger
from starlette.responses import JSONResponse

from src.common.exception import MyException
from src.web.common.dto import Result


def register_exception_handlers(app: FastAPI):
    @app.exception_handler(MyException)
    async def my_exception_handler(request: Request, exc: MyException):
        logger.warning(f"【自定义异常】exception={exc}")
        return JSONResponse(Result.fail(msg=exc.msg, code=exc.code).model_dump())

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception):
        # 建议打印 traceback，方便定位
        tb = "".join(traceback.format_exception(type(exc), exc, exc.__traceback__))
        msg = f"【未捕获异常】path={request.url.path} exception={exc}\n{tb}"
        logger.error(msg)
        return JSONResponse(status_code=500, content=Result.fail(msg=msg, code="UNKNOW").model_dump())

    logger.info("register exception handlers success")


def init_app() -> FastAPI:
    my_app = FastAPI()
    my_app.add_middleware(GZipMiddleware, minimum_size=1000)
    register_exception_handlers(my_app)
    return my_app
