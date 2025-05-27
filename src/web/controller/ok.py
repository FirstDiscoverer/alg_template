from fastapi import APIRouter

from src.web.common.dto import Result

router = APIRouter()


@router.get("/ok")
def ok():
    return Result()
