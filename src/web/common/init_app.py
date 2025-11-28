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

    logger.info("register exception handlers success")


def init_app() -> FastAPI:
    my_app = FastAPI()
    my_app.add_middleware(GZipMiddleware, minimum_size=1000)
    register_exception_handlers(my_app)
    return my_app
