"""FastAPI 入口"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import settings
from .database import Base, engine
from .routers import feed, users

# 启动时建表（dev 够用；生产请改用 Alembic 迁移）
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="小蓝书 API",
    description="短视频 + 图文笔记社区 — 登录 / 用户 / Feed（笔记+视频）",
    version="0.2.0",
)

# CORS（Flutter Web / 本机调试用）
origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins or ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users.router)
app.include_router(feed.router)


@app.get("/", tags=["meta"])
def root():
    return {
        "name": "xiaolanbook-api",
        "version": "0.2.0",
        "docs": "/docs",
        "endpoints": [
            "POST   /api/users/register",
            "POST   /api/users/login",
            "POST   /api/users/send-sms",
            "GET    /api/users/me     (Bearer)",
            "GET    /api/users/health",
            "GET    /api/notes        (双 Feed: 图文)",
            "GET    /api/videos       (双 Feed: 视频)",
            "POST   /api/notes        (Bearer)",
            "POST   /api/videos       (Bearer)",
            "GET    /api/notes/{id}/comments",
            "POST   /api/{note|video}/{id}/like",
            "POST   /api/{note|video}/{id}/favorite",
            "GET    /api/me/likes     (Bearer)",
            "GET    /api/me/favorites (Bearer)",
        ],
    }