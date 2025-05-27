from typing import Any

from pydantic import BaseModel

from src.common.exception import DEFAULT_EXCEPTION_CODE


class Result(BaseModel):
    # trace_id: Optional[str] = None
    success: bool = True
    code: str = "0"
    msg: str = None
    data: Any = None

    @staticmethod
    def fail(msg: str, code: str = DEFAULT_EXCEPTION_CODE) -> "Result":
        return Result(success=False, code=code, msg=msg)
