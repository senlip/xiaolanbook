"""应用配置 — 从环境变量 / .env 文件读取"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # 数据库
    database_url: str = "sqlite:///./xiaolanbook.db"

    # JWT
    secret_key: str = "dev-secret-change-me-please-32bytes-min"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 1440  # 24h

    # CORS
    cors_origins: str = "*"

    # 短信（dev 占位）
    sms_dev_code: str = "123456"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )


settings = Settings()