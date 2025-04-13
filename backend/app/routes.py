# app/routes.py

from flask import Blueprint, request, jsonify
from app.models import db, User, Measure
from datetime import datetime

# Création d'un Blueprint pour organiser les routes
main = Blueprint("main", __name__)

# === 🔁 Test de connectivité API ===
@main.route("/ping", methods=["GET"])
def ping():
    return jsonify({"message": "L'API fonctionne correctement !"})

# === 👤 Création d'un utilisateur ===
@main.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()
    user = User(
        name=data.get("name"),
        email=data.get("email"),
        password=data.get("password")
    )
    db.session.add(user)
    db.session.commit()
    return jsonify({"message": "Utilisateur créé avec succès", "user_id": user.id}), 201

# === 📋 Liste des utilisateurs ===
@main.route("/users", methods=["GET"])
def get_users():
    users = User.query.all()
    return jsonify([
        {"id": u.id, "name": u.name, "email": u.email, "role": u.role}
        for u in users
    ])

# === 🧍 Détails d’un utilisateur ===
@main.route("/users/<int:user_id>", methods=["GET"])
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return jsonify({
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role
    })

# === ➕ Enregistrer une mesure de santé ===
@main.route("/measures", methods=["POST"])
def create_measure():
    data = request.get_json()
    measure = Measure(
        user_id=data["user_id"],
        date=datetime.strptime(data["date"], "%Y-%m-%d %H:%M:%S"),
        glycemia=data.get("glycemia"),
        systolic=data.get("systolic"),
        diastolic=data.get("diastolic"),
        temperature=data.get("temperature")
    )
    db.session.add(measure)
    db.session.commit()
    return jsonify({"message": "Mesure enregistrée avec succès", "measure_id": measure.id}), 201

# === 📈 Liste des mesures d’un utilisateur ===
@main.route("/measures/<int:user_id>", methods=["GET"])
def get_measures_by_user(user_id):
    measures = Measure.query.filter_by(user_id=user_id).order_by(Measure.date.desc()).all()
    return jsonify([
        {
            "id": m.id,
            "date": m.date.strftime("%Y-%m-%d %H:%M:%S"),
            "glycemia": m.glycemia,
            "systolic": m.systolic,
            "diastolic": m.diastolic,
            "temperature": m.temperature
        }
        for m in measures
    ])

# === 📊 Dernière mesure d’un utilisateur ===
@main.route("/measures/latest/<int:user_id>", methods=["GET"])
def get_latest_measure(user_id):
    m = Measure.query.filter_by(user_id=user_id).order_by(Measure.date.desc()).first()
    if not m:
        return jsonify({"erreur": "Aucune mesure trouvée"}), 404
    return jsonify({
        "id": m.id,
        "date": m.date.strftime("%Y-%m-%d %H:%M:%S"),
        "glycemia": m.glycemia,
        "systolic": m.systolic,
        "diastolic": m.diastolic,
        "temperature": m.temperature
    })
