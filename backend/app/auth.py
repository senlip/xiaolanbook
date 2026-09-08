"""密码哈希 + JWT 签发与解码"""
from datetime import datetime, timedelta, timezone

import bcrypt
from jose import JWTError, jwt

from .config import settings


def _truncate_for_bcrypt(password: str) -> bytes:
    """bcrypt 限制 72 字节 — 超长密码先截断（避免 ValueError）"""
    return password.encode("utf-8")[:72]


def hash_password(plain: str) -> str:
    """明文密码 → bcrypt hash (成本 12)"""
    salt = bcrypt.gensalt(rounds=12)
    digest = bcrypt.hashpw(_truncate_for_bcrypt(plain), salt)
    return digest.decode("utf-8")


def verify_password(plain: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(_truncate_for_bcrypt(plain), hashed.encode("utf-8"))
    except (ValueError, TypeError):
        return False


def create_access_token(subject: str | int, extra: dict | None = None) -> str:
    """签发 JWT；subject 通常放 user.id"""
    now = datetime.now(timezone.utc)
    payload = {
        "sub": str(subject),
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(minutes=settings.access_token_expire_minutes)).timestamp()),
    }
    if extra:
        payload.update(extra)
    return jwt.encode(payload, settings.secret_key, algorithm=settings.algorithm)


def decode_token(token: str) -> dict:
    """解码 JWT，失败抛 JWTError"""
    try:
        return jwt.decode(token, settings.secret_key, algorithms=[settings.algorithm])
    except JWTError as e:
        raise JWTError(f"invalid token: {e}")