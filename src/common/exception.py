import asyncio
import logging
from enum import Enum
from functools import wraps

DEFAULT_EXCEPTION_CODE, DEFAULT_EXCEPTION_MSG = '-1', '服务出现异常'


class MyException(Exception):

    def __init__(self, code: str = DEFAULT_EXCEPTION_CODE, msg: str = DEFAULT_EXCEPTION_MSG):
        self.code = code
        self.msg = msg

    def __str__(self):
        return f"MyException, code={self.code}, msg={self.msg}"


class ExceptionEnum(Enum):
    DEFAULT = (DEFAULT_EXCEPTION_CODE, DEFAULT_EXCEPTION_MSG)

    def __init__(self, code: str, msg: str):
        self.code = code
        self.msg = msg

    def to_exception(self):
        raise MyException(code=self.code, msg=self.msg)


class MyExceptionWrapper:
    def __init__(self, code: str = ExceptionEnum.DEFAULT.code,
                 msg: str = ExceptionEnum.DEFAULT.msg,
                 add_exception: bool = True):
        self.__code = code
        self.__msg = msg
        self.__add_exception = add_exception

    def __parse_exception(self, e: Exception):
        if isinstance(e, MyException):
            raise e
        logging.exception(f"exception={e}")
        if self.__add_exception:
            e_str = str(e) if str(e) else repr(e)
            msg = f"{self.__msg}, exception={e_str}"
        else:
            msg = self.__msg
        return MyException(msg=msg, code=self.__code)

    def __call__(self, func):
        @wraps(func)
        def wrapped_function(*args, **kwargs):
            try:
                result = func(*args, **kwargs)
            except Exception as e:
                raise self.__parse_exception(e)
            return result

        @wraps(func)
        async def async_wrapped_function(*args, **kwargs):
            try:
                result = await func(*args, **kwargs)
            except Exception as e:
                raise self.__parse_exception(e)
            return result

        return async_wrapped_function if asyncio.iscoroutinefunction(func) else wrapped_function
