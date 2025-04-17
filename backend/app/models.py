from app import db

# ============================
# 🔹 Modèle : Utilisateur
# ============================
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text)
    email = db.Column(db.Text, unique=True, nullable=False)
    password = db.Column(db.Text, nullable=False)
    role = db.Column(db.String(20), default="patient")
    last_password_change = db.Column(db.DateTime)

    measures = db.relationship('Measure', backref='user', lazy=True)
    reminders = db.relationship('Reminder', backref='user', lazy=True)
    alerts = db.relationship('Alert', backref='user', lazy=True)
    reports = db.relationship('Report', backref='user', lazy=True)
    medications = db.relationship('Medication', backref='user', lazy=True)
    appointments = db.relationship('Appointment', backref='user', lazy=True)

# ============================
# 🔹 Modèle : Mesure médicale
# ============================
class Measure(db.Model):
    __tablename__ = 'measure'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    date = db.Column(db.DateTime, nullable=False)
    glycemia = db.Column(db.Float)
    systolic = db.Column(db.Float)
    diastolic = db.Column(db.Float)
    temperature = db.Column(db.Float)

# ============================
# 🔹 Rappel (notification)
# ============================
class Reminder(db.Model):
    __tablename__ = 'reminder'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    title = db.Column(db.String(100))
    description = db.Column(db.Text)
    date_time = db.Column(db.DateTime, nullable=False)

# ============================
# 🔹 Alerte automatique
# ============================
class Alert(db.Model):
    __tablename__ = 'alert'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    type = db.Column(db.String(100))
    level = db.Column(db.String(50))
    message = db.Column(db.Text)
    date_sent = db.Column(db.DateTime)

# ============================
# 🔹 Rapport généré
# ============================
class Report(db.Model):
    __tablename__ = 'report'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    date_generated = db.Column(db.DateTime, nullable=False)
    content = db.Column(db.Text)

# ============================
# 🔹 Médicament
# ============================
class Medication(db.Model):
    __tablename__ = 'medication'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    name = db.Column(db.Text, nullable=False)
    dosage = db.Column(db.Text)
    note = db.Column(db.Text)
    date_prescribed = db.Column(db.DateTime)

    schedules = db.relationship('MedicationSchedule', backref='medication', lazy=True, cascade='all, delete-orphan')

# ============================
# 🔹 Horaire de prise (schedules)
# ============================
class MedicationSchedule(db.Model):
    __tablename__ = 'medication_schedule'

    id = db.Column(db.Integer, primary_key=True)
    medication_id = db.Column(db.Integer, db.ForeignKey('medication.id', ondelete='CASCADE'), nullable=False)
    time = db.Column(db.Time, nullable=False)
    taken = db.Column(db.Boolean, default=False)
    note = db.Column(db.Text)

# ============================
# 🔹 Rendez-vous
# ============================
class Appointment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    title = db.Column(db.Text)
    location = db.Column(db.Text)
    doctor = db.Column(db.Text)
    date_time = db.Column(db.DateTime)
    notes = db.Column(db.Text)

# ============================
# 🔹 Conseils santé
# ============================
class HealthTip(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    type = db.Column(db.Text)  # ex: "activité", "alimentation", etc.
    created_at = db.Column(db.DateTime, server_default=db.func.now())
