import stripe
from fastapi import Depends, FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware

from src.auth.dependency import Role, UsersAllowed
from src.auth.router import auth_router
from src.config import settings
from src.payments.configs import stripe_settings
from src.payments.router import payment_router
from src.users.router import user_router

app = FastAPI(
    title="Nuge API",
    description="Nuge API",
    version="1.0.0",
    docs_url="/docs" if settings.supabase_url else None,  # Disable docs in production
    redoc_url=None,  # Disable redoc for security
)

# Secure CORS configuration
allowed_origins = [
    "https://nuge.app", # Production
    "http://localhost:3000", # React dev server
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,  # Restrict to specific origins
    allow_credentials=True,  # Allow cookies/auth headers
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],  # Specific methods only
    allow_headers=["Authorization", "Content-Type"],  # Specific headers only
)


# Security headers middleware
@app.middleware("http")
async def add_security_headers(request: Request, call_next):
    """Add security headers to all responses"""
    response: Response = await call_next(request)
    
    # Security headers for family management app
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"  # Prevent iframe embedding
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
    response.headers["Content-Security-Policy"] = "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'"
    
    return response


app.include_router(auth_router, prefix="/api/v1")
app.include_router(user_router, prefix="/api/v1") 
app.include_router(payment_router, prefix="/api/v1")  # Comment out if payment is not needed

stripe.api_key = stripe_settings.stripe_api_key


@app.get("/health")
async def health_check():
    """Health check endpoint for monitoring"""
    return {"status": "healthy", "version": "1.0.0"}

