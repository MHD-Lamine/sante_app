# 💡 Application intelligente de suivi santé (diabète & hypertension)

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Build with Docker](https://img.shields.io/badge/docker-ready-blue)](./docker-compose.yml)
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
sante_app/
├── backend/        → API Flask avec PostgreSQL
├── frontend/       → Application Flutter mobile
├── ai/             → Modèles IA, Jupyter Notebooks
├── arduino/        → Code du bracelet connecté (Arduino)
├── n8n/            → Automatisation (alertes, PDF)
├── database/       → Script SQL
├── docker-compose.yml → Orchestration des conteneurs
├── docs/           → Diagrammes, cahier des charges
```

---

## 🚀 Lancer le projet avec Docker

### 1. Cloner le projet

```bash
git clone https://github.com/MHD-Lamine/sante_app.git
cd sante_app
```

### 2. Copier les variables d’environnement

```bash
cp backend/.env.example backend/.env
```

Puis remplacer `SECRET_KEY` et `JWT_SECRET_KEY` par des valeurs aléatoires :

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

### 3. Lancer tous les services

```bash
docker-compose up --build
```

### 4. Créer / mettre à jour les tables

```bash
# Première fois uniquement (le dossier migrations/ n'est pas versionné)
docker-compose exec web flask db init
docker-compose exec web flask db migrate -m "init"

docker-compose exec web flask db upgrade
```

---

## 🔌 Accès API (Flask)

- Test de fonctionnement : `GET /ping`
- Utilisateurs :
  - `POST /users` (inscription)
  - `POST /login`, `POST /refresh`
  - `GET /profile`, `PUT /profile`, `PUT /change_password`
- Mesures (utilisateur du token JWT) :
  - `POST /measures`
  - `GET /measures`
- Médicaments :
  - `POST /medications`, `GET /medications`
  - `PUT /medications/schedules/<id>/take`
- Rendez-vous : `POST /appointments`, `GET /appointments`
- Conseils santé : `GET /healthtips`

---

# 📱 Application Flutter – Suivi Santé (Diabète & Hypertension)

Une application mobile intelligente pour le suivi des personnes atteintes de maladies chroniques : **diabète** et **hypertension**.  
Elle est connectée à une API sécurisée développée avec Flask + JWT.

---

## 🚀 Fonctionnalités principales

### 👤 Authentification

- `POST /login` : connexion sécurisée avec JWT
- Stockage du token avec `flutter_secure_storage`

### 🧾 Gestion du profil

- `GET /profile` : récupération des données utilisateur
- `PUT /profile` : modification du nom, email, mot de passe
- `PUT /change_password` : changement sécurisé du mot de passe

### 📈 Suivi santé (à venir)

- Visualisation des mesures : glycémie, tension, température
- Ajout de nouvelles mesures santé

---

## 🛠️ Technologies

| Frontend (Mobile)        | Backend (API)        |
| ------------------------ | -------------------- |
| Flutter 3+               | Flask + JWT          |
| `http`                   | Flask-CORS           |
| `flutter_secure_storage` | PostgreSQL + Alembic |
| Material Design          | Docker + REST        |

---

## 🗂️ Structure du projet

```
lib/
├── screens/
│   ├── login_screen.dart
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   └── change_password_screen.dart
├── services/
│   └── api_service.dart
```

---

## 🔐 Authentification JWT

- Le token est généré à la connexion (`/login`)
- Stocké localement dans le téléphone
- Utilisé dans toutes les requêtes sécurisées via `Authorization: Bearer <token>`

---

## ✅ Exécution

### 📲 Lancer l'app Flutter

```bash
flutter pub get
flutter run
```

> Sur Android Emulator, utilisez `http://10.0.2.2:5000`  
> Sur téléphone réel, utilisez l’IP locale du PC dans `api_service.dart`

### 🐳 Lancer l'API Flask

```bash
docker-compose up --build
```

---

## ✍️ Auteur

** Diabate Mohamed Lamine **  
Master 2 Génie Informatique – Université Nangui Abrogoua

---

## 📝 Licence

## Projet académique à usage pédagogique

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
