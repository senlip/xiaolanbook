"""用户相关端点 — 对应原 APK /api/users/register /api/users/login 等"""
import random
import re

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..auth import create_access_token, hash_password, verify_password
from ..config import settings
from ..deps import get_current_user
from ..database import get_db
from ..models import User
from ..schemas import LoginIn, MeOut, OkOut, RegisterIn, SendSmsIn, SmsOut, TokenOut, UserOut

router = APIRouter(prefix="/api/users", tags=["users"])

_PHONE_RE = re.compile(r"^1[3-9]\d{9}$")


def _normalize_phone(p: str) -> str:
    if not _PHONE_RE.match(p):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="手机号格式错误")
    return p


# -------------------- 注册 --------------------

@router.post("/register", response_model=TokenOut, status_code=status.HTTP_201_CREATED)
def register(payload: RegisterIn, db: Session = Depends(get_db)) -> TokenOut:
    phone = _normalize_phone(payload.phone)

    existing = db.query(User).filter(User.phone == phone).first()
    if existing:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="该手机号已注册")

    user = User(
        phone=phone,
        nickname=payload.nickname or f"书友{phone[-4:]}",
        password_hash=hash_password(payload.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    token = create_access_token(user.id)
    return TokenOut(access_token=token, user=UserOut.model_validate(user))


# -------------------- 登录 --------------------

@router.post("/login", response_model=TokenOut)
def login(payload: LoginIn, db: Session = Depends(get_db)) -> TokenOut:
    phone = _normalize_phone(payload.phone)

    user = db.query(User).filter(User.phone == phone).first()
    if not user or not verify_password(payload.password, user.password_hash):
        # 故意用同一句话，防止被探测账号是否存在
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="手机号或密码错误")
    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="账号已停用")

    token = create_access_token(user.id)
    return TokenOut(access_token=token, user=UserOut.model_validate(user))


# -------------------- 发送验证码（占位实现） --------------------

@router.post("/send-sms", response_model=SmsOut)
def send_sms(payload: SendSmsIn) -> SmsOut:
    """
    ⚠️ 占位实现：生产必须接阿里云 / 腾讯云 SMS。
    当前默认返回 dev 固定码 `settings.sms_dev_code`，并打印日志便于调试。
    """
    phone = _normalize_phone(payload.phone)
    print(f"[SMS] would send to {phone}, dev code = {settings.sms_dev_code}")
    return SmsOut(sent=True, expires_in=240)


# -------------------- 当前用户信息 --------------------

@router.get("/me", response_model=MeOut)
def me(current: User = Depends(get_current_user)) -> MeOut:
    return MeOut(user=UserOut.model_validate(current))


# -------------------- 健康检查 --------------------

@router.get("/health", response_model=OkOut)
def health() -> OkOut:
    return OkOut(ok=True)