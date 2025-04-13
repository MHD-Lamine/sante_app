# Import du module os pour accéder aux variables d'environnement du système
import os

# Import de la fonction load_dotenv pour charger automatiquement les variables d’un fichier .env
from dotenv import load_dotenv

# Chargement des variables définies dans le fichier .env (s'il existe)
load_dotenv()

# Définition de la classe de configuration principale utilisée par Flask
class Config:
    # Définition de l'URL de connexion à la base de données PostgreSQL
    # Elle est lue depuis la variable d'environnement DATABASE_URL
    # Si cette variable n'existe pas, une URL par défaut est utilisée
    SQLALCHEMY_DATABASE_URI = os.getenv(
        "DATABASE_URL", 
        "postgresql://postgres:postgres@db:5432/suivi_sante"
    )

    # Désactive le suivi des modifications d'objet par SQLAlchemy
    # Cela améliore les performances et évite les avertissements inutiles
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    # Clé secrète utilisée pour sécuriser les sessions Flask ou les tokens JWT
    # Elle est lue depuis le fichier .env ou définie par défaut (à modifier en production)
    SECRET_KEY = os.getenv("SECRET_KEY", "dev_secret_key")

    # Mode debug activé (affiche les erreurs détaillées et recharge automatique du serveur)
    # À désactiver dans un environnement de production
    DEBUG = True
