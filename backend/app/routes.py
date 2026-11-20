from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    jwt_required, create_access_token, create_refresh_token,
    get_jwt_identity
)
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
from app.models import db, User, Measure, Medication, MedicationSchedule, Appointment, HealthTip

main = Blueprint("main", __name__)

def current_user_id():
    # Le "sub" du JWT est une chaîne (exigé par Flask-JWT-Extended >= 4.7)
    return int(get_jwt_identity())

# === 🧪 Test API
@main.route("/ping", methods=["GET"])
def ping():
    return jsonify({"message": "API OK"}), 200

# === 🔐 Authentification
@main.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    if not data or not data.get("email") or not data.get("password"):
        return jsonify({"msg": "Champs manquants"}), 400

    user = User.query.filter_by(email=data["email"]).first()
    if not user or not check_password_hash(user.password, data["password"]):
        return jsonify({"msg": "Identifiants invalides"}), 401

    access_token = create_access_token(identity=str(user.id), expires_delta=timedelta(minutes=15))
    refresh_token = create_refresh_token(identity=str(user.id))

    return jsonify({
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user_id": user.id,
        "name": user.name
    }), 200

@main.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    identity = get_jwt_identity()
    new_access_token = create_access_token(identity=identity, expires_delta=timedelta(minutes=15))
    return jsonify({"access_token": new_access_token}), 200

# === 🔐 Enregistrement
@main.route("/users", methods=["POST"])
def register():
    data = request.get_json()
    if not data or not all(k in data for k in ["name", "email", "password"]):
        return jsonify({"error": "Champs requis : name, email, password"}), 400
    if User.query.filter_by(email=data["email"]).first():
        return jsonify({"error": "Email déjà utilisé"}), 409

    new_user = User(
        name=data["name"],
        email=data["email"],
        password=generate_password_hash(data["password"]),
        role=data.get("role", "patient"),
        last_password_change=datetime.utcnow()
    )
    db.session.add(new_user)
    db.session.commit()
    return jsonify({"message": "Inscription réussie"}), 201

# === 👤 Profil utilisateur
@main.route("/profile", methods=["GET"])
@jwt_required()
def get_profile():
    user = User.query.get_or_404(current_user_id())
    return jsonify({
        "id": user.id, "name": user.name,
        "email": user.email, "role": user.role
    })

@main.route("/profile", methods=["PUT"])
@jwt_required()
def update_profile():
    user = User.query.get_or_404(current_user_id())
    data = request.get_json()
    if "name" in data: user.name = data["name"]
    if "email" in data: user.email = data["email"]
    if "password" in data: user.password = generate_password_hash(data["password"])
    db.session.commit()
    return jsonify({"message": "Profil mis à jour"}), 200

@main.route("/change_password", methods=["PUT"])
@jwt_required()
def change_password():
    user = User.query.get_or_404(current_user_id())
    data = request.get_json() or {}
    if not data.get("old_password") or not data.get("new_password"):
        return jsonify({"msg": "Champs requis : old_password, new_password"}), 400
    if not check_password_hash(user.password, data["old_password"]):
        return jsonify({"msg": "Ancien mot de passe incorrect"}), 401
    user.password = generate_password_hash(data["new_password"])
    user.last_password_change = datetime.utcnow()
    db.session.commit()
    return jsonify({"msg": "Mot de passe mis à jour"}), 200

# === 📏 Mesures
@main.route("/measures", methods=["POST"])
@jwt_required()
def create_measure():
    try:
        user_id = current_user_id()
        data = request.get_json()
        measure = Measure(
            user_id=user_id,
            date=datetime.strptime(data["date"], "%Y-%m-%d %H:%M:%S"),
            glycemia=data.get("glycemia"),
            systolic=data.get("systolic"),
            diastolic=data.get("diastolic"),
            temperature=data.get("temperature")
        )
        db.session.add(measure)
        db.session.commit()
        return jsonify({"message": "Mesure enregistrée"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@main.route("/measures", methods=["GET"])
@jwt_required()
def get_measures():
    user_id = current_user_id()
    measures = Measure.query.filter_by(user_id=user_id).order_by(Measure.date.desc()).all()
    return jsonify([
        {
            "id": m.id, "date": m.date.strftime("%Y-%m-%d %H:%M:%S"),
            "glycemia": m.glycemia, "systolic": m.systolic,
            "diastolic": m.diastolic, "temperature": m.temperature
        } for m in measures
    ])

# === 💊 Médicaments
@main.route("/medications", methods=["POST"])
@jwt_required()
def create_medication():
    try:
        user_id = current_user_id()
        data = request.get_json()
        med = Medication(
            user_id=user_id,
            name=data.get("name"),
            dosage=data.get("dosage"),
            date_prescribed=datetime.strptime(data["date_prescribed"], "%Y-%m-%d %H:%M:%S") if data.get("date_prescribed") else None,
            note=data.get("note")
        )
        db.session.add(med)
        db.session.commit()

        for sched in data.get("schedules", []):
            schedule = MedicationSchedule(
                medication_id=med.id,
                time=datetime.strptime(sched["time"], "%H:%M").time(),
                taken=sched.get("taken", False),
                note=sched.get("note")
            )
            db.session.add(schedule)
        db.session.commit()
        return jsonify({"message": "Médicament ajouté"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@main.route("/medications", methods=["GET"])
@jwt_required()
def get_medications():
    user_id = current_user_id()
    meds = Medication.query.filter_by(user_id=user_id).all()
    return jsonify([
        {
            "id": m.id,
            "name": m.name,
            "dosage": m.dosage,
            "note": m.note,
            "date_prescribed": m.date_prescribed.strftime("%Y-%m-%d %H:%M:%S") if m.date_prescribed else None,
            "schedules": [
                {
                    "id": s.id,
                    "time": s.time.strftime("%H:%M"),
                    "taken": s.taken,
                    "note": s.note
                } for s in m.schedules
            ]
        } for m in meds
    ])

@main.route("/medications/schedules/<int:schedule_id>/take", methods=["PUT"])
@jwt_required()
def mark_schedule_as_taken(schedule_id):
    # On ne peut marquer que les prises de ses propres médicaments
    sched = (MedicationSchedule.query
             .join(Medication)
             .filter(MedicationSchedule.id == schedule_id,
                     Medication.user_id == current_user_id())
             .first_or_404())
    sched.taken = True
    db.session.commit()
    return jsonify({"message": "Prise marquée comme faite"}), 200

@main.route("/reset-medications", methods=["POST"])
def reset_medications():
    # Réservé au cron du conteneur (reset_meds.sh appelle localhost)
    if request.remote_addr not in ("127.0.0.1", "::1"):
        return jsonify({"msg": "Accès refusé"}), 403
    for sched in MedicationSchedule.query.all():
        sched.taken = False
    db.session.commit()
    return jsonify({"message": "Toutes les prises ont été réinitialisées"}), 200

# === 📅 Rendez-vous
@main.route("/appointments", methods=["POST"])
@jwt_required()
def create_appointment():
    try:
        user_id = current_user_id()
        data = request.get_json()
        appt = Appointment(
            user_id=user_id,
            title=data["title"],
            location=data["location"],
            doctor=data.get("doctor"),
            date_time=datetime.strptime(data["date_time"], "%Y-%m-%d %H:%M:%S"),
            notes=data.get("notes")
        )
        db.session.add(appt)
        db.session.commit()
        return jsonify({"message": "Rendez-vous créé"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 400

@main.route("/appointments", methods=["GET"])
@jwt_required()
def get_appointments():
    user_id = current_user_id()
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

# === 📘 Conseils santé
@main.route("/healthtips", methods=["GET"])
def get_health_tips():
    tips = HealthTip.query.order_by(HealthTip.created_at.desc()).limit(5).all()
    return jsonify([
        {
            "id": t.id,
            "type": t.type,
            "content": t.content,
            "created_at": t.created_at.strftime("%Y-%m-%d %H:%M:%S")
        } for t in tips
    ])
