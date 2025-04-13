# 💡 Application intelligente de suivi santé (diabète & hypertension)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Build with Docker](https://img.shields.io/badge/docker-ready-blue)](./docker)
[![Made with Flask](https://img.shields.io/badge/backend-flask-green)](./backend)
[![Made with Flutter](https://img.shields.io/badge/frontend-flutter-blue)](./frontend)

---

## 🧠 Description

Cette application permet à des patients atteints de maladies chroniques (diabète et hypertension) de suivre leurs données de santé au quotidien.

Les fonctionnalités principales incluent :
- Enregistrement des mesures (glycémie, tension, température)
- Graphiques interactifs de suivi
- Alertes intelligentes automatiques (IA)
- Rappels personnalisés
- Génération de rapports PDF
- Communication avec un bracelet connecté via Bluetooth

---

## 📁 Structure du projet

```
suivi_sante/
├── backend/        → API Flask avec PostgreSQL
├── frontend/       → Application Flutter mobile
├── ai/             → Modèles IA, Jupyter Notebooks
├── arduino/        → Code du bracelet connecté (Arduino)
├── n8n/            → Automatisation (alertes, PDF)
├── docker/         → docker-compose + configuration conteneurs
├── docs/           → Diagrammes, cahier des charges
```

---

## 🚀 Lancer le projet avec Docker

### 1. Cloner le projet

```bash
git clone https://github.com/TON-UTILISATEUR/suivi-sante-app.git
cd suivi-sante-app
```

### 2. Copier les variables d’environnement

```bash
cp backend/.env.example backend/.env
```

### 3. Lancer tous les services

```bash
docker-compose -f docker/docker-compose.yml up --build
```

---

## 🔌 Accès API (Flask)

- Test de fonctionnement : `GET /ping`
- Utilisateurs :
  - `POST /users`
  - `GET /users`
- Mesures :
  - `POST /measures`
  - `GET /measures/<user_id>`
  - `GET /measures/latest/<user_id>`

---

## 📱 Application Flutter

- À ouvrir dans VS Code / Android Studio
- Fichiers dans `frontend/lib/`

---

## 🧠 Intelligence Artificielle

- Notebooks dans `ai/notebooks/`
- Modèles de prédiction entraînés sur données simulées

---

## ⚙️ Automatisation avec n8n

- Fichiers exportés dans `n8n/workflows.json`
- Envoi d’emails, alertes, PDF via webhook ou planification

---

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE).