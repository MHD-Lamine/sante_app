# app/routes.py

from flask import Blueprint, request, jsonify
from app.models import Alert, Appointment, HealthTip, Medication, Reminder, Report, db, User, Measure
from datetime import datetime

from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash


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

    hashed_password = generate_password_hash(data.get("password"))  # 🔐 Hash

    user = User(
        name=data.get("name"),
        email=data.get("email"),
        password=hashed_password  # Enregistre le mot de passe hashé
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
    user = User.query.filter_by(email=data.get("email")).first()

    if not user or not check_password_hash(user.password, data.get("password")):
        return jsonify({"msg": "Email ou mot de passe incorrect"}), 401

    access_token = create_access_token(identity=str(user.id))  # ✅ ICI
    return jsonify({
        "access_token": access_token,
        "user_id": user.id,
        "name": user.name
    }), 200

# === Acceder au profil ===
@main.route("/profile", methods=["GET"])
@jwt_required()
def get_profile():
    print("✅ Requête GET /profile reçue")
    print("Headers :", dict(request.headers))
    
    try:
        request.get_json(force=False, silent=True)
    except Exception as e:
        print("Erreur silencieuse JSON :", e)

    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)

    return jsonify({
        "id": user.id,
        "name": user.name,
        "email": user.email,
        "role": user.role
    })

# === Profil update vvvvv ===
@main.route("/profile", methods=["PUT"])
@jwt_required()
def update_profile():
    user_id = get_jwt_identity()  # 🔐 Récupère l'ID à partir du token
    user = User.query.get_or_404(user_id)

    data = request.get_json()

    # Mise à jour des champs autorisés
    if "name" in data:
        user.name = data["name"]
    if "email" in data:
        user.email = data["email"]
    if "password" in data:
        user.password = data["password"]  # à sécuriser plus tard (hash)

    db.session.commit()

    return jsonify({
        "message": "Profil mis à jour",
        "user": {
            "id": user.id,
            "name": user.name,
            "email": user.email
        }
    })


@main.route("/change_password", methods=["PUT"])
@jwt_required()
def change_password():
    user_id = get_jwt_identity()  # 🔐 Utilisateur connecté via JWT
    user = User.query.get_or_404(user_id)

    data = request.get_json()
    old_password = data.get("old_password")
    new_password = data.get("new_password")

    # 🔐 Vérifie que l'ancien mot de passe est correct
    if not check_password_hash(user.password, old_password):
        return jsonify({"msg": "Mot de passe actuel incorrect"}), 401

    # Hash du nouveau mot de passe
    user.password = generate_password_hash(new_password)
    db.session.commit()

    return jsonify({"msg": "Mot de passe mis à jour avec succès"}), 200



# === Créer un médicament ===
@main.route("/medications", methods=["POST"])
@jwt_required()
def create_medication():
    user_id = get_jwt_identity()
    data = request.get_json()

    med = Medication(
        user_id=user_id,
        name=data.get("name"),
        dosage=data.get("dosage"),
        time=data.get("time"),
        taken=data.get("taken", False),
        date_prescribed=datetime.strptime(data["date_prescribed"], "%Y-%m-%d %H:%M:%S") if "date_prescribed" in data else None,
        note=data.get("note")
    )
    db.session.add(med)
    db.session.commit()
    return jsonify({"message": "Médicament ajouté"}), 201

# === Liste des médicaments d’un utilisateur ===
@main.route("/medications", methods=["GET"])
@jwt_required()
def get_medications():
    user_id = get_jwt_identity()
    meds = Medication.query.filter_by(user_id=user_id).all()
    return jsonify([
        {
            "id": m.id,
            "name": m.name,
            "dosage": m.dosage,
            "time": m.time,
            "taken": m.taken,
            "date_prescribed": m.date_prescribed.strftime("%Y-%m-%d %H:%M:%S") if m.date_prescribed else None,
            "note": m.note
        } for m in meds
    ])

# === Supprimer un médicament ===
@main.route("/medications/<int:med_id>", methods=["DELETE"])
@jwt_required()
def delete_medication(med_id):
    med = Medication.query.get_or_404(med_id)
    db.session.delete(med)
    db.session.commit()
    return jsonify({"message": "Médicament supprimé"})



@main.route("/appointments", methods=["POST"])
@jwt_required()
def create_appointment():
    user_id = get_jwt_identity()
    data = request.get_json()

    rdv = Appointment(
        user_id=user_id,
        title=data.get("title"),
        location=data.get("location"),
        doctor=data.get("doctor"),
        date_time=datetime.strptime(data["date_time"], "%Y-%m-%d %H:%M:%S"),
        notes=data.get("notes")
    )
    db.session.add(rdv)
    db.session.commit()
    return jsonify({"message": "Rendez-vous créé"}), 201

@main.route("/appointments", methods=["GET"])
@jwt_required()
def get_appointments():
    user_id = get_jwt_identity()
    appts = Appointment.query.filter_by(user_id=user_id).order_by(Appointment.date_time.asc()).all()
    return jsonify([
        {
            "id": a.id,
            "title": a.title,
            "location": a.location,
            "doctor": a.doctor,
            "date_time": a.date_time.strftime("%Y-%m-%d %H:%M:%S"),
            "notes": a.notes
        } for a in appts
    ])

@main.route("/appointments/<int:appt_id>", methods=["DELETE"])
@jwt_required()
def delete_appointment(appt_id):
    appt = Appointment.query.get_or_404(appt_id)
    db.session.delete(appt)
    db.session.commit()
    return jsonify({"message": "Rendez-vous supprimé"})


@main.route("/health_tips", methods=["GET"])
def get_health_tips():
    tips = HealthTip.query.order_by(HealthTip.created_at.desc()).limit(5).all()
    return jsonify([
        {
            "id": t.id,
            "content": t.content,
            "type": t.type,
            "created_at": t.created_at.strftime("%Y-%m-%d")
        } for t in tips
    ])
