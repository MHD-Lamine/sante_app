# run.py

# On importe la fonction qui crée l'application
from app import create_app

# On appelle la factory pour instancier l'app Flask
app = create_app()

# Ce bloc permet de lancer le serveur uniquement si ce script est exécuté directement
if __name__ == "__main__":
    # Lancement du serveur Flask en mode debug (port 5000 par défaut)
    app.run(host='0.0.0.0', port=5000, debug=True)
