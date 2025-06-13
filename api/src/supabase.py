from supabase import create_client, Client
from typing import Optional
from .config import settings


def get_supabase_client() -> Optional[Client]:
    """
    Create and return a Supabase client.
    Returns None if using placeholder values for development.
    """
    # Check if we're using placeholder values
    if (settings.SUPABASE_URL == "https://placeholder.supabase.co" or 
        settings.SUPABASE_KEY == "placeholder_key"):
        print("Warning: Using placeholder Supabase credentials. Supabase client disabled.")
        return None
    
    try:
        return create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)
    except Exception as e:
        print(f"Warning: Failed to create Supabase client: {e}")
        return None


supabase = get_supabase_client()