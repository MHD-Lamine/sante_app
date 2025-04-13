FROM python:3.12.2
# Utilise une image officielle Python optimisée

# Définit le dossier de travail dans le conteneur
WORKDIR /app

# Copie les fichiers de dépendances
COPY requirements.txt .

# Installation des dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Copie tout le reste du code dans le conteneur
COPY . .

# Expose le port Flask (5000)
EXPOSE 5000

# Commande pour démarrer l'application Flask
CMD ["python", "run.py"]
