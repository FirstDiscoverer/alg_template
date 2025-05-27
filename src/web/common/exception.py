import logging

from fastapi import Request
from fastapi.responses import JSONResponse

from src.common.exception import MyException
from src.web.common.constant import my_app
from src.web.common.dto import Result


@my_app.exception_handler(MyException)
async def my_exception_handler(request: Request, exc: MyException):
    logging.warning(f"【自定义异常】exception={exc}")
    return JSONResponse(Result.fail(msg=exc.msg, code=exc.code).model_dump())


def init_exception():
    # 必须import，上面的方法才会生效
    logging.info('init exception success')
