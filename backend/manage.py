# manage.py

# Importation du script principal Flask
from app import create_app, db

# Import de Flask-Migrate pour ajouter les commandes db
from flask_migrate import MigrateCommand
from flask_script import Manager

# Création de l'application Flask à partir de la factory
app = create_app()

# Initialisation du manager de commandes
manager = Manager(app)

# Ajout de la commande "db" pour gérer les migrations via terminal
manager.add_command('db', MigrateCommand)

# Lancement des commandes (ex: python manage.py db init)
if __name__ == '__main__':
    manager.run()
#docker-compose exec web bash
