from flask import Blueprint, request, jsonify
from app.models import (
    Alert, Appointment, HealthTip, Medication, MedicationSchedule,
    Reminder, Report, db, User, Measure
)
from datetime import date, datetime
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from werkzeug.security import generate_password_hash, check_password_hash

main = Blueprint("main", __name__)

# === Test API ===
@main.route("/ping", methods=["GET"])
def ping():
    return jsonify({"message": "L'API fonctionne correctement !"})

# === Authentification ===
@main.route("/login", methods=["POST"])
def login():
    data = request.get_json()
    user = User.query.filter_by(email=data.get("email")).first()

    if not user or not check_password_hash(user.password, data.get("password")):
        return jsonify({"msg": "Email ou mot de passe incorrect"}), 401

    access_token = create_access_token(identity=str(user.id))
    return jsonify({
        "access_token": access_token,
        "user_id": user.id,
        "name": user.name
    }), 200

# === Création d'utilisateur ===
@main.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()
    hashed_password = generate_password_hash(data.get("password"))
    user = User(name=data.get("name"), email=data.get("email"), password=hashed_password)
    db.session.add(user)
    db.session.commit()
    return jsonify({"message": "Utilisateur créé", "user_id": user.id}), 201

# === Profil ===
@main.route("/profile", methods=["GET"])
@jwt_required()
def get_profile():
    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)
    return jsonify({
        "id": user.id, "name": user.name, "email": user.email, "role": user.role
    })

@main.route("/profile", methods=["PUT"])
@jwt_required()
def update_profile():
    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    if "name" in data:
        user.name = data["name"]
    if "email" in data:
        user.email = data["email"]
    if "password" in data:
        user.password = data["password"]
    db.session.commit()
    return jsonify({"message": "Profil mis à jour"})

@main.route("/change_password", methods=["PUT"])
@jwt_required()
def change_password():
    user_id = get_jwt_identity()
    user = User.query.get_or_404(user_id)
    data = request.get_json()
    if not check_password_hash(user.password, data.get("old_password")):
        return jsonify({"msg": "Mot de passe actuel incorrect"}), 401
    user.password = generate_password_hash(data["new_password"])
    db.session.commit()
    return jsonify({"msg": "Mot de passe mis à jour avec succès"}), 200

# === Mesures médicales ===
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
    return jsonify({"message": "Mesure enregistrée"}), 201

@main.route("/measures/<int:user_id>", methods=["GET"])
def get_measures_by_user(user_id):
    measures = Measure.query.filter_by(user_id=user_id).order_by(Measure.date.desc()).all()
    return jsonify([
        {
            "id": m.id, "date": m.date.strftime("%Y-%m-%d %H:%M:%S"),
            "glycemia": m.glycemia, "systolic": m.systolic,
            "diastolic": m.diastolic, "temperature": m.temperature
        } for m in measures
    ])

@main.route("/measures/latest/<int:user_id>", methods=["GET"])
def get_latest_measure(user_id):
    m = Measure.query.filter_by(user_id=user_id).order_by(Measure.date.desc()).first()
    if not m:
        return jsonify({"erreur": "Aucune mesure trouvée"}), 404
    return jsonify({
        "id": m.id, "date": m.date.strftime("%Y-%m-%d %H:%M:%S"),
        "glycemia": m.glycemia, "systolic": m.systolic,
        "diastolic": m.diastolic, "temperature": m.temperature
    })

# === Médicaments + horaires ===
@main.route("/medications", methods=["POST"])
@jwt_required()
def create_medication():
    user_id = get_jwt_identity()
    data = request.get_json()
    med = Medication(
        user_id=user_id,
        name=data.get("name"),
        dosage=data.get("dosage"),
        date_prescribed=datetime.strptime(data["date_prescribed"], "%Y-%m-%d %H:%M:%S") if "date_prescribed" in data else None,
        note=data.get("note")
    )
    db.session.add(med)
    db.session.commit()

    for sched in data.get("schedules", []):
        time_obj = datetime.strptime(sched["time"], "%H:%M").time()
        schedule = MedicationSchedule(
            medication_id=med.id,
            time=time_obj,
            taken=sched.get("taken", False),
            note=sched.get("note")
        )
        db.session.add(schedule)
    db.session.commit()
    return jsonify({"message": "Médicament ajouté avec horaires"}), 201

@main.route("/medications/<int:user_id>", methods=["GET"])
#@jwt_required()
def get_medications_by_user(user_id):
    medications = Medication.query.filter_by(user_id=user_id).all()
    result = []
    for med in medications:
        result.append({
            "id": med.id,
            "name": med.name,
            "dosage": med.dosage,
            "note": med.note,
            "date_prescribed": med.date_prescribed.strftime("%Y-%m-%d %H:%M:%S") if med.date_prescribed else None,
            "schedules": [
                {
                    "id": s.id,
                    "time": s.time.strftime("%H:%M"),
                    "taken": s.taken,
                    "note": s.note
                } for s in med.schedules
            ]
        })
    return jsonify(result)

@main.route("/medications/schedules/<int:schedule_id>/take", methods=["PUT"])
@jwt_required()
def mark_schedule_as_taken(schedule_id):
    schedule = MedicationSchedule.query.get_or_404(schedule_id)
    schedule.taken = True
    db.session.commit()
    return jsonify({"message": "Prise marquée comme faite"}), 200

@main.route("/medications/<int:med_id>", methods=["DELETE"])
@jwt_required()
def delete_medication(med_id):
    med = Medication.query.get_or_404(med_id)
    db.session.delete(med)
    db.session.commit()
    return jsonify({"message": "Médicament supprimé"}), 200

# === Rappels
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
    return jsonify({"message": "Rappel créé"}), 201

@main.route("/reminders/<int:user_id>", methods=["GET"])
def get_reminders(user_id):
    reminders = Reminder.query.filter_by(user_id=user_id).all()
    return jsonify([
        {
            "id": r.id, "title": r.title,
            "description": r.description,
            "date_time": r.date_time.strftime("%Y-%m-%d %H:%M:%S")
        } for r in reminders
    ])

# === Alertes
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
    return jsonify({"message": "Alerte créée"}), 201

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

# === Rapports
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
    return jsonify({"message": "Rapport créé"}), 201

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

# === Rendez-vous
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
#@jwt_required()
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

@main.route("/appointments/<int:user_id>", methods=["GET"])
@jwt_required()
def get_appointments_for_user(user_id):  # ✅ Nouveau nom unique
    appointments = Appointment.query.filter_by(user_id=user_id).order_by(Appointment.date_time).all()
    return jsonify([
        {
            "id": a.id,
            "title": a.title,
            "doctor": a.doctor,
            "location": a.location,
            "date_time": a.date_time.strftime("%Y-%m-%d %H:%M:%S"),
            "notes": a.notes
        } for a in appointments
    ])


@main.route("/appointments/<int:appt_id>", methods=["DELETE"])
@jwt_required()
def delete_appointment(appt_id):
    appt = Appointment.query.get_or_404(appt_id)
    db.session.delete(appt)
    db.session.commit()
    return jsonify({"message": "Rendez-vous supprimé"}), 200

# === Conseils santé
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



@main.route("/reset-medications", methods=["POST"])
def reset_medications():
    schedules = MedicationSchedule.query.all()
    for sched in schedules:
        sched.taken = False
    db.session.commit()
    return jsonify({"message": "Toutes les prises ont été réinitialisées"}), 200
