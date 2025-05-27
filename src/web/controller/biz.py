from fastapi import APIRouter
from pydantic import BaseModel

from src.web.common.dto import Result
from src.web.common.exception import MyException

router = APIRouter(prefix="/my_prefix", )


class ReqInfo(BaseModel):
    # trace_id: Optional[str] = Field(default_factory=lambda: str(uuid.uuid1()).replace('-', ''))  # 全链路追踪ID
    text: str


@router.post('/my_path')
async def controller(req_info: ReqInfo):
    text = req_info.text
    if text != 'hello':  # 输入校验
        raise MyException(msg='输入不是hello')
    return Result(data={'input': text})
