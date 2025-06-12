from typing import List
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # Supabase Configuration
    supabase_url: str
    supabase_key: str
    supabase_jwt_secret_key: str
    supabase_db_conn_str: str
    
    # Environment Configuration
    environment: str = "development"  # development, staging, production
    debug: bool = True
    
    # Security Configuration
    allowed_origins: List[str] = [
        "http://localhost:3000",
    ]
    
    # Rate Limiting
    rate_limit_requests_per_minute: int = 100
    
    # Logging
    log_level: str = "INFO"
    
    @property
    def is_production(self) -> bool:
        """Check if running in production environment"""
        return self.environment.lower() == "production"
    
    @property
    def is_development(self) -> bool:
        """Check if running in development environment"""
        return self.environment.lower() == "development"

    class Config:
        env_file = ".env"
        extra = "ignore"


settings = Settings()
