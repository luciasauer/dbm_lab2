from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from faker import Faker
import random
from datetime import datetime, timedelta
from models import *

# Database connection URL
DB_NAME = "dbm-db"
DB_USER = "postgres"
DB_PASSWORD = "bse1234"
DB_HOST = "localhost"
DB_PORT = "5432"
DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

# Create DB session
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)
session = Session()

faker = Faker()

def populate_customers(n=1000):
    for _ in range(n):
        customer = Customer(
            first_name=faker.first_name(),
            last_name=faker.last_name(),
            email=faker.unique.email(),
            address=faker.address(),
            phone_number=faker.phone_number()
        )
        session.add(customer)
    session.commit()

def populate_aircraft(n=50):
    for _ in range(n):
        aircraft = Aircraft(
            aircraft_type=faker.word(),
            registration_number=faker.unique.bothify(text='??###')
        )
        session.add(aircraft)
    session.commit()

def populate_aircraft_seats(n=5):
    
    existing_aircraft_ids = {aircraft.id for aircraft in session.query(Aircraft).all()}
    
    for aircraft_id in existing_aircraft_ids:
        for row in range(1, random.choice([33, 45, 60])):
            for letter in ['A', 'B', 'C', 'D', 'E', 'F']:
                seat = AircraftSeats(
                    aircraft_id=aircraft_id,
                    seat_row=str(row),
                    seat_letter=letter,
                    seat_type=random.choice(['BUSINESS', 'PREMIUM', 'ECONOMIC'])
                )
                session.add(seat)

    session.commit()

def populate_flights():
    flight_slot_ids = {slot.id for slot in session.query(AircraftSlot).filter_by(type='FLIGHT').all()}
    for slot_id in flight_slot_ids:
        flight = Flight(
            slot_id=slot_id,
            origin=faker.city(),
            destination=faker.city(),
            miles=random.randint(100, 5000),
            selling_airline=faker.company(),
            operating_airline=faker.company()
        )
        session.add(flight)
    session.commit()

def populate_bookings(n=20):
    for _ in range(n):
        booking = Booking(
            customer_id=random.randint(1, 10),
            flight_id=random.randint(1, 10)
        )
        session.add(booking)
    session.commit()

def populate_booking_details(n=20):
    booking_ids = {booking.id for booking in session.query(Booking).all()}
    for booking_id in booking_ids:
        booking_detail = BookingDetails(
            booking_id=booking_id,
            aircraft_id=random.randint(1, 5),
            seat_row=str(random.randint(1, 10)),
            seat_letter=random.choice(['A', 'B', 'C', 'D', 'E', 'F']),
            price=round(random.uniform(50, 2500), 2),
            purchase_timestamp=faker.date_time_this_year(),
            payment_status=random.choice(['ACCEPTED', 'REJECTED']),
            booking_status=random.choice(['CONFIRMED', 'CANCELED']),
            last_updated=datetime.now()
        )
        session.add(booking_detail)
    session.commit()

def populate_flight_status(n=10):
    for flight_id in range(1, n + 1):
        status = FlightStatus(
            flight_id=flight_id,
            status=random.choice(['SCHEDULED', 'CANCELED', 'DELAYED']),
            last_updated=datetime.now()
        )
        session.add(status)
    session.commit()

def populate_aircraft_crew(n=10):
    for _ in range(n):
        crew_member = AircraftCrew(
            first_name=faker.first_name(),
            last_name=faker.last_name(),
            role=random.choice(['PILOT', 'COPILOT', 'STEWARDESS'])
        )
        session.add(crew_member)
    session.commit()

def populate_crew_assignments(n=20):
    for _ in range(n):
        flight_id = random.randint(1, 10)
        crew_id = random.randint(1, 10)
        
        existing_assignment = session.query(CrewAssignment).filter_by(flight_id=flight_id, crew_id=crew_id).first()
        if existing_assignment is None:
            assignment = CrewAssignment(
                flight_id=flight_id,
                crew_id=crew_id,
                assignment_date=datetime.now()
            )
            session.add(assignment)
    session.commit()

def populate_maintenance_events():
    maintenance_slot_ids = {slot.id for slot in session.query(AircraftSlot).filter_by(type='MAINTENANCE').all()}
    for slot_id in maintenance_slot_ids:
        event = MaintenanceEvent(
            slot_id=slot_id,
            is_scheduled=random.choice([True, False]),
            airport=faker.city()
        )
        session.add(event)
    session.commit()

def populate_aircraft_slots(n=100):
    for _ in range(n):
        start_datetime = faker.date_time_this_year()
        end_datetime = start_datetime + timedelta(hours=random.randint(1, 5))
            
        slot = AircraftSlot(
            aircraft_id=random.randint(1, 5),
            type=random.choices(['FLIGHT', 'MAINTENANCE'], weights=[0.8, 0.2])[0],
            start_datetime=start_datetime,
            end_datetime=end_datetime,
        )
        session.add(slot)
    
    session.commit()

def populate_reporters(n=5):
    for _ in range(n):
        reporter = Reporter(
            first_name=faker.first_name(),
            last_name=faker.last_name(),
            reporter_role=random.choice(['PILOT', 'MAINTENANCE PERSONNEL'])
        )
        session.add(reporter)
    session.commit()

def populate_work_orders():
    me_ids = {slot.id for slot in session.query(MaintenanceEvent).all()}
    for maint_ev_id in me_ids:
        order = WorkOrder(
            maintenance_event_id=maint_ev_id,
            execution_place=faker.city(),
            execution_date=faker.date_this_year(),
            is_scheduled = random.choices([True, False], weights=[0.65, 0.35])[0]
        )
        session.add(order)
    session.commit()

def populate_aircraft_oos():
    me_ids = {me.id for me in session.query(MaintenanceEvent).filter(MaintenanceEvent.is_scheduled==True).all()}
    for maintenance_event_id in me_ids:
        oos = AircraftOOS(
            maintenance_event_id=maintenance_event_id,
            event_subtype=random.choice(['MAINTENANCE', 'REVISION'])
        )
        session.add(oos)
    session.commit()

def populate_operational_interruptions():
    me_ids = {me.id for me in session.query(MaintenanceEvent).filter(MaintenanceEvent.is_scheduled==False).all()}
    for maintenance_event_id in me_ids:
        interruption = OperationalInterruption(
            maintenance_event_id=maintenance_event_id,
            flight_id=random.randint(1, 10),
            event_subtype=random.choice(['DELAY', 'SAFETY'])
        )
        session.add(interruption)
    session.commit()

def populate_work_order_scheduled():
    wo_ids = {slot.id for slot in session.query(WorkOrder).filter_by(is_scheduled=True).all()}
    for work_order_id in wo_ids:
        scheduled = WorkOrderScheduled(
            work_order_id=work_order_id,
            forecasted_date=faker.date_this_year(),
            forecasted_man_hours=random.randint(1, 10)
        )
        session.add(scheduled)
    session.commit()

def populate_work_order_unscheduled():
    wo_ids = {slot.id for slot in session.query(WorkOrder).filter_by(is_scheduled=False).all()}
    for work_order_id in wo_ids:
        unscheduled = WorkOrderUnscheduled(
            work_order_id=work_order_id,
            reporter_id=random.randint(1, 5),
            due_date=faker.date_this_year(),
            reporting_date=faker.date_this_year() if random.choice([True, False]) else None
        )
        session.add(unscheduled)
    
    session.commit()

def populate_customer_preferences(n=1000):
    customer_ids = {customer.id for customer in session.query(Customer).all()}
    for customer_id in customer_ids:
        preferences = CustomerPreferences(
            customer_id=customer_id,
            preferences={
            "meal": random.choice(["vegetarian", "non-vegetarian", "vegan"]),
            "seating": {
                "aisle": random.choice([True, False]),
                "extra_legroom": random.choice([True, False]),
                "seat_near_exit": random.choice([True, False])
            },
            "notifications": {
                "email": random.choice([True, False]),
                "sms": random.choice([True, False])
            }
            }
        )
        session.add(preferences)
    session.commit()

def populate_aircraft_maintenance_logs(n=100):
    aircraft_ids = {aircraft.id for aircraft in session.query(Aircraft).all()}
    for aircraft_id in aircraft_ids:
        for _ in range(n):
            log = AircraftMaintenanceLogs(
                aircraft_maintenance_id=aircraft_id,
                logs={
                    "date": faker.date_this_year().isoformat(),
                    "check_type": random.choice(["Full Inspection", "Routine Check", "Safety Check"]),
                    "components_checked": [
                        {
                            "name": "Engine",
                            "status": random.choice(["Operational", "Requires Service", "Replaced"]),
                            "last_replaced": faker.date_this_decade().isoformat() if random.choice([True, False]) else None
                        },
                        {
                            "name": "Hydraulics",
                            "status": random.choice(["Operational", "Requires Service", "Replaced"]),
                            "last_replaced": faker.date_this_decade().isoformat() if random.choice([True, False]) else None
                        },
                        {
                            "name": "Avionics",
                            "status": random.choice(["Operational", "Requires Service", "Replaced"]),
                            "last_replaced": faker.date_this_decade().isoformat() if random.choice([True, False]) else None
                        }
                    ]
                }
            )
            session.add(log)
    session.commit()

def populate_customer_feedback(n=1000):
    customer_ids = {customer.id for customer in session.query(Customer).all()}
    flight_ids = {flight.id for flight in session.query(Flight).all()}
    for _ in range(n):
        feedback = CustomerFeedback(
            customer_id=random.choice(list(customer_ids)),
            flight_id=random.choice(list(flight_ids)),
            feedback={
            "survey_date": faker.date_this_year().isoformat(),
            "rating": random.randint(1, 5),
            "comments": faker.text(),
            "topics": {
                "comfort": random.randint(1, 5),
                "service": random.randint(1, 5),
                "cleanliness": random.randint(1, 5),
                "entertainment": random.randint(1, 5)
            }
            }
        )
        session.add(feedback)
    session.commit()


if __name__ == '__main__':
    populate_customers(10000)
    populate_aircraft(50)
    populate_aircraft_seats(5000)
    populate_aircraft_slots(200)
    populate_flights()
    populate_bookings(5000)
    populate_booking_details(5000)
    populate_flight_status(100)
    populate_aircraft_crew(500)
    populate_crew_assignments(500)
    populate_maintenance_events()
    populate_reporters(50)
    populate_work_orders()
    populate_aircraft_oos()
    populate_operational_interruptions()
    populate_work_order_scheduled()
    populate_work_order_unscheduled()
    populate_customer_preferences(750)
    populate_aircraft_maintenance_logs(350)
    populate_customer_feedback(400)

    print("Database populated with fake data.")
