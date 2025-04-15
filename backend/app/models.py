# Importation du module db initialisé dans __init__.py
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

    # Relations vers les autres tables
    measures = db.relationship('Measure', backref='user', lazy=True)
    reminders = db.relationship('Reminder', backref='user', lazy=True)
    alerts = db.relationship('Alert', backref='user', lazy=True)
    reports = db.relationship('Report', backref='user', lazy=True)

# ============================
# 🔹 Modèle : Mesure médicale
# ============================
class Measure(db.Model):
    __tablename__ = 'measure'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)  # Lien vers un utilisateur

    # Données médicales
    date = db.Column(db.DateTime, nullable=False)
    glycemia = db.Column(db.Float)
    systolic = db.Column(db.Float)
    diastolic = db.Column(db.Float)
    temperature = db.Column(db.Float)

# ============================
# 🔹 Modèle : Rappel (notification programmée)
# ============================
class Reminder(db.Model):
    __tablename__ = 'reminder'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    title = db.Column(db.String(100))
    description = db.Column(db.Text)
    date_time = db.Column(db.DateTime, nullable=False)  # Quand le rappel doit être déclenché

# ============================
# 🔹 Modèle : Alerte automatique
# ============================
class Alert(db.Model):
    __tablename__ = 'alert'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    type = db.Column(db.String(100))        # Type d'alerte : tension haute, hypoglycémie, etc.
    level = db.Column(db.String(50))        # Critique, modéré, léger...
    message = db.Column(db.Text)            # Message à afficher/envoyer
    date_sent = db.Column(db.DateTime)      # Date de génération de l'alerte

# ============================
# 🔹 Modèle : Rapport généré
# ============================
class Report(db.Model):
    __tablename__ = 'report'

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

    date_generated = db.Column(db.DateTime, nullable=False)
    content = db.Column(db.Text)            # Contenu brut ou lien vers un PDF

class Medication(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    name = db.Column(db.Text, nullable=False)
    dosage = db.Column(db.Text)
    time = db.Column(db.Text)  # "matin", "midi", "soir"
    taken = db.Column(db.Boolean, default=False)
    date_prescribed = db.Column(db.DateTime)
    note = db.Column(db.Text)

    user = db.relationship("User", backref="medications")

class Appointment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    title = db.Column(db.Text)
    location = db.Column(db.Text)
    doctor = db.Column(db.Text)
    date_time = db.Column(db.DateTime)
    notes = db.Column(db.Text)

    user = db.relationship("User", backref="appointments")

class HealthTip(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    type = db.Column(db.Text)  # ex: "activité", "alimentation", "repos"
    created_at = db.Column(db.DateTime, server_default=db.func.now())
