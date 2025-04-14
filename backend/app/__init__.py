# app/__init__.py

from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
from flask_jwt_extended import JWTManager  # 🔐 JWT

db = SQLAlchemy()
migrate = Migrate()
jwt = JWTManager()  # 🔐 Instance JWT

def create_app():
    app = Flask(__name__)
    CORS(app)

    # Charger config depuis config.py (inclut la clé JWT)
    app.config.from_object("app.config.Config")

    db.init_app(app)
    migrate.init_app(app, db)
    jwt.init_app(app)  # 🔐 Initialisation JWT

    # Charger les modèles
    from app import models

    # Enregistrer les routes
    from app.routes import main
    app.register_blueprint(main)

    return app
