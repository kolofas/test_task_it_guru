from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        extra="ignore",
    )

    database_url: str

    postgres_db: str | None = None
    postgres_user: str | None = None
    postgres_password: str | None = None


settings = Settings()