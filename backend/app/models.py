# Importation du module db initialisé dans __init__.py
from app import db

# ============================
# 🔹 Modèle : Utilisateur
# ============================
class User(db.Model):
    __tablename__ = 'user'  # Nom explicite de la table dans la base

    # Clé primaire unique pour chaque utilisateur
    id = db.Column(db.Integer, primary_key=True)

    # Champs de base pour l'utilisateur
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(256), nullable=False)    
    role = db.Column(db.String(50), default='patient')  # Ex : patient, admin

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
