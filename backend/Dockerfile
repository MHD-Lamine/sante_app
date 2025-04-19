FROM python:3.12.2

# 📁 Dossier de travail dans le conteneur
WORKDIR /app

# 🧪 Copier les dépendances d'abord pour optimisation du cache Docker
COPY requirements.txt .

# 🔧 Installer les paquets Python
RUN pip install --no-cache-dir -r requirements.txt

# 📂 Créer le dossier des logs cron
RUN mkdir -p /var/log && touch /var/log/cron.log

# 📦 Copier tous les fichiers du projet (y compris reset_meds.sh et meds-cron)
COPY . .

# ✅ Donner les bons droits APRÈS avoir copié les fichiers
RUN chmod +x reset_meds.sh \
    && chmod 0644 meds-cron

# 📌 Enregistrer la tâche cron dans le système
RUN apt-get update && apt-get install -y cron curl \
    && crontab meds-cron

# 📡 Exposer le port Flask
EXPOSE 5000

# 🟢 Démarrer le service cron + l'app Flask
CMD cron && python run.py
