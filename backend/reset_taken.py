# reset_taken.py
from app import create_app, db
from app.models import MedicationSchedule

def reset_taken_status():
    app = create_app()
    with app.app_context():
        updated = MedicationSchedule.query.filter_by(taken=True).update({'taken': False})
        db.session.commit()
        print(f"✅ {updated} prises ont été remises à 'à prendre'.")

if __name__ == "__main__":
    reset_taken_status()
