"""Pydantic 数据契约 — API 请求与响应"""
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field, field_validator


# ---------- 注册 / 登录 ----------

class RegisterIn(BaseModel):
    phone: str = Field(..., min_length=11, max_length=11, description="11 位手机号")
    password: str = Field(..., min_length=6, max_length=64)
    nickname: str | None = Field(None, max_length=64)

    @field_validator("phone")
    @classmethod
    def _check_phone_digits(cls, v: str) -> str:
        if not v.isdigit():
            raise ValueError("手机号必须全为数字")
        return v


class LoginIn(BaseModel):
    phone: str = Field(..., min_length=11, max_length=11)
    password: str = Field(..., min_length=6, max_length=64)


class SendSmsIn(BaseModel):
    phone: str = Field(..., min_length=11, max_length=11)


# ---------- 输出 ----------

class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    phone: str
    nickname: str
    avatar_url: str | None
    gender: str | None
    bio: str | None
    created_at: datetime


class TokenOut(BaseModel):
    """登录 / 注册成功响应 — access_token + 用户信息"""
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class MeOut(BaseModel):
    user: UserOut


class SmsOut(BaseModel):
    sent: bool
    expires_in: int  # 秒


class OkOut(BaseModel):
    ok: bool = True


# ---------- 笔记 / 视频 ----------

class AuthorBrief(BaseModel):
    """列表项内嵌的作者简版信息"""
    model_config = ConfigDict(from_attributes=True)

    id: int
    nickname: str
    avatar_url: str | None = None


class NoteOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str | None
    content: str
    image_urls: list[str] = []
    likes_count: int = 0
    comments_count: int = 0
    created_at: datetime
    author: AuthorBrief
    # 当前用户是否已点赞/收藏（需登录上下文）
    liked: bool = False
    favorited: bool = False

    @field_validator("image_urls", mode="before")
    @classmethod
    def _image_urls_to_list(cls, v):
        """ORM 里存逗号分隔字符串，输出转 list"""
        if isinstance(v, str):
            return [u for u in v.split(",") if u] if v else []
        return v or []


class VideoOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    title: str | None
    description: str | None
    video_url: str
    cover_url: str | None
    duration_ms: int | None
    likes_count: int = 0
    comments_count: int = 0
    created_at: datetime
    author: AuthorBrief
    liked: bool = False
    favorited: bool = False


class NoteCreateIn(BaseModel):
    title: str | None = Field(None, max_length=200)
    content: str = Field(..., min_length=1, max_length=20000)
    image_urls: list[str] = []


class VideoCreateIn(BaseModel):
    title: str | None = Field(None, max_length=200)
    description: str | None = Field(None, max_length=2000)
    video_url: str = Field(..., max_length=512)
    cover_url: str | None = Field(None, max_length=512)
    duration_ms: int | None = None


class CommentCreateIn(BaseModel):
    content: str = Field(..., min_length=1, max_length=1000)


class CommentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    user_id: int
    content: str
    created_at: datetime
    user: AuthorBrief


class ToggleOut(BaseModel):
    """点赞/收藏切换结果"""
    target_type: str
    target_id: int
    active: bool
    likes_count: int | None = None
    favorited: bool | None = None