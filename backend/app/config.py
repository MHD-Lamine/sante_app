import os
from datetime import timedelta
from dotenv import load_dotenv

# Charge les variables d’environnement depuis un fichier .env
load_dotenv()

class Config:
    # === 🔐 Sécurité générale ===
    SECRET_KEY = os.getenv("SECRET_KEY", "dev_secret_key")  # ⚠️ À changer en production

    # === 🗄️ Base de données ===
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL",
        "postgresql://postgres:postgres@db:5432/suivi_sante"
    )
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # === 🪙 JSON Web Tokens (JWT) ===
    JWT_SECRET_KEY = os.getenv("JWT_SECRET_KEY", "dev_jwt_secret")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=15)   # Access token court
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)     # Refresh token long
    JWT_TOKEN_LOCATION = ["headers"]
    JWT_COOKIE_CSRF_PROTECT = False  # Si tu utilises les headers, pas de protection CSRF

    # === 🐞 Mode debug ===
    DEBUG = os.getenv("FLASK_DEBUG", "true").lower() == "true"
