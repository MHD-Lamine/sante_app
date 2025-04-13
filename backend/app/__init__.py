from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS

db = SQLAlchemy()
migrate = Migrate()

def create_app():
    app = Flask(__name__)
    CORS(app)

    # Charger la configuration
    app.config.from_object("app.config.Config")

    # Initialiser SQLAlchemy & Migrate
    db.init_app(app)
    migrate.init_app(app, db)

    # 🛠 Importer les modèles ici, une fois db initialisé
    from app import models

    # Importer les routes
    from app.routes import main
    app.register_blueprint(main)

    return app
