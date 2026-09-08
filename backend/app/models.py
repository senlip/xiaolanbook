"""ORM 模型"""
from datetime import datetime

from sqlalchemy import (
    BigInteger,
    Boolean,
    DateTime,
    ForeignKey,
    Integer,
    String,
    Text,
    UniqueConstraint,
    func,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from .database import Base


class User(Base):
    """用户表 — 手机号作为登录账号（覆盖原 APK /api/users/register 的最小字段）"""
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    phone: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=False)
    nickname: Mapped[str] = mapped_column(String(64), nullable=False, default="小蓝书用户")
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    avatar_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    gender: Mapped[str | None] = mapped_column(String(1), nullable=True)  # 'M' / 'F' / None
    bio: Mapped[str | None] = mapped_column(String(255), nullable=True)

    is_active: Mapped[bool] = mapped_column(Boolean, nullable=False, default=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now(), onupdate=func.now()
    )

    notes: Mapped[list["Note"]] = relationship(back_populates="author")
    videos: Mapped[list["Video"]] = relationship(back_populates="author")


class Note(Base):
    """图文笔记（双 Feed 之一，对应原 APK /api/notes）"""
    __tablename__ = "notes"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    author_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    title: Mapped[str | None] = mapped_column(String(200), nullable=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    # 图片 URL，逗号分隔（最多 9 图，对应小红书式多图笔记）
    image_urls: Mapped[str | None] = mapped_column(Text, nullable=True)
    likes_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    comments_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now(), index=True
    )

    author: Mapped["User"] = relationship(back_populates="notes")


class Video(Base):
    """短视频（双 Feed 之二，对应原 APK /api/videos）"""
    __tablename__ = "videos"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    author_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    title: Mapped[str | None] = mapped_column(String(200), nullable=True)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    video_url: Mapped[str] = mapped_column(String(512), nullable=False)
    cover_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    duration_ms: Mapped[int | None] = mapped_column(Integer, nullable=True)
    likes_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    comments_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now(), index=True
    )

    author: Mapped["User"] = relationship(back_populates="videos")


class Comment(Base):
    """评论（笔记 + 视频通用，原 APK Comment / VideoComment）"""
    __tablename__ = "comments"
    __table_args__ = (UniqueConstraint("user_id", "target_type", "target_id"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    target_type: Mapped[str] = mapped_column(String(10), nullable=False)  # 'note' / 'video'
    target_id: Mapped[int] = mapped_column(Integer, index=True, nullable=False)
    content: Mapped[str] = mapped_column(String(1000), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )


class Like(Base):
    """点赞（笔记 + 视频通用，原 APK ToggleCallback）"""
    __tablename__ = "likes"
    __table_args__ = (UniqueConstraint("user_id", "target_type", "target_id"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    target_type: Mapped[str] = mapped_column(String(10), nullable=False)  # 'note' / 'video'
    target_id: Mapped[int] = mapped_column(Integer, index=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )


class Favorite(Base):
    """收藏（原 APK /api/me/favorites）"""
    __tablename__ = "favorites"
    __table_args__ = (UniqueConstraint("user_id", "target_type", "target_id"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[int] = mapped_column(
        Integer, ForeignKey("users.id", ondelete="CASCADE"), index=True, nullable=False
    )
    target_type: Mapped[str] = mapped_column(String(10), nullable=False)  # 'note' / 'video'
    target_id: Mapped[int] = mapped_column(Integer, index=True, nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime, nullable=False, server_default=func.now()
    )