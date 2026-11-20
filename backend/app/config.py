import os
from datetime import timedelta
from dotenv import load_dotenv

# Charge les variables d’environnement depuis un fichier .env
load_dotenv()

def _required(name):
    value = os.getenv(name)
    if not value:
        raise RuntimeError(f"Variable d'environnement manquante : {name} (voir backend/.env.example)")
    return value

class Config:
    # === 🔐 Sécurité générale ===
    SECRET_KEY = _required("SECRET_KEY")

    # === 🗄️ Base de données ===
    SQLALCHEMY_DATABASE_URI = _required("DATABASE_URL")
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # === 🪙 JSON Web Tokens (JWT) ===
    JWT_SECRET_KEY = _required("JWT_SECRET_KEY")
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(minutes=15)   # Access token court
    JWT_REFRESH_TOKEN_EXPIRES = timedelta(days=30)     # Refresh token long
    JWT_TOKEN_LOCATION = ["headers"]
    JWT_COOKIE_CSRF_PROTECT = False  # Si tu utilises les headers, pas de protection CSRF

    # === 🐞 Mode debug ===
    DEBUG = os.getenv("FLASK_DEBUG", "false").lower() == "true"
