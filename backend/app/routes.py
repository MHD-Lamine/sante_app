# app/routes.py

from flask import Blueprint, request, jsonify
from app.models import Alert, Reminder, Report, db, User, Measure
from datetime import datetime

from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import check_password_hash


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

@main.route("/alerts", methods=["POST"])
def create_alert():
    data = request.get_json()
    alert = Alert(
        user_id=data["user_id"],
        type=data["type"],
        level=data["level"],
        message=data["message"],
        date_sent=datetime.strptime(data["date_sent"], "%Y-%m-%d %H:%M:%S")
    )
    db.session.add(alert)
    db.session.commit()
    return jsonify({"message": "Alert créer"}), 201

@main.route("/alerts/<int:user_id>", methods=["GET"])
def get_alerts(user_id):
    alerts = Alert.query.filter_by(user_id=user_id).order_by(Alert.date_sent.desc()).all()
    return jsonify([
        {
            "id": a.id,
            "type": a.type,
            "level": a.level,
            "message": a.message,
            "date_sent": a.date_sent.strftime("%Y-%m-%d %H:%M:%S")
        } for a in alerts
    ])

@main.route("/reports", methods=["POST"])
def create_report():
    data = request.get_json()
    report = Report(
        user_id=data["user_id"],
        date_generated=datetime.strptime(data["date_generated"], "%Y-%m-%d %H:%M:%S"),
        content=data["content"]
    )
    db.session.add(report)
    db.session.commit()
    return jsonify({"message": "Rapport créer"}), 201

@main.route("/reports/<int:user_id>", methods=["GET"])
def get_reports(user_id):
    reports = Report.query.filter_by(user_id=user_id).order_by(Report.date_generated.desc()).all()
    return jsonify([
        {
            "id": r.id,
            "date_generated": r.date_generated.strftime("%Y-%m-%d %H:%M:%S"),
            "content": r.content
        } for r in reports
    ])

@main.route("/reminders", methods=["POST"])
def create_reminder():
    data = request.get_json()
    reminder = Reminder(
        user_id=data["user_id"],
        title=data["title"],
        description=data.get("description", ""),
        date_time=datetime.strptime(data["date_time"], "%Y-%m-%d %H:%M:%S")
    )
    db.session.add(reminder)
    db.session.commit()
    return jsonify({"message": "Rappel créer"}), 201

@main.route("/reminders/<int:user_id>", methods=["GET"])
def get_reminders(user_id):
    reminders = Reminder.query.filter_by(user_id=user_id).all()
    return jsonify([
        {
            "id": r.id,
            "title": r.title,
            "description": r.description,
            "date_time": r.date_time.strftime("%Y-%m-%d %H:%M:%S")
        } for r in reminders
    ])


# === Login ===
@main.route("/login", methods=["POST"])
def login():
    data = request.get_json()

    # Recherche de l'utilisateur par email
    user = User.query.filter_by(email=data.get("email")).first()

    # Vérification du mot de passe (à adapter si hashé)
    if not user or user.password != data.get("password"):
        return jsonify({"msg": "Email ou mot de passe incorrect"}), 401

    # Génération du token JWT avec l'identité (ID utilisateur)
    access_token = create_access_token(identity=user.id)

    return jsonify({
        "access_token": access_token,
        "user_id": user.id,
        "name": user.name
    }), 200
