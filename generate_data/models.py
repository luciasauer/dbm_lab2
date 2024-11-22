from sqlalchemy import (create_engine, Column, Integer, Float, Boolean, String, DateTime, Date, 
                        ForeignKey, text, PrimaryKeyConstraint, ForeignKeyConstraint, CheckConstraint)
from sqlalchemy.orm import declarative_base, sessionmaker, relationship
from sqlalchemy.dialects.postgresql import JSONB
from faker import Faker
import random
from datetime import datetime, timedelta

Base = declarative_base()

class Customer(Base):
    __tablename__ = 'customer'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    address = Column(String(100), nullable=False)
    phone_number = Column(String(100), nullable=False)

class Aircraft(Base):
    __tablename__ = 'aircraft'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    aircraft_type = Column(String(50), nullable=False)
    registration_number = Column(String(50), unique=True, nullable=False)

class AircraftSeats(Base):
    __tablename__ = 'aircraft_seats'
    
    aircraft_id = Column(Integer, ForeignKey('aircraft.id', ondelete='CASCADE'), primary_key=True, nullable=False)
    seat_row = Column(String(10), primary_key=True, nullable=False)
    seat_letter = Column(String(1), primary_key=True, nullable=False)
    seat_type = Column(String(20), nullable=False, check_constraint="seat_type IN ('BUSINESS', 'PREMIUM', 'ECONOMIC')")

class Flight(Base):
    __tablename__ = 'flight'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    slot_id = Column(Integer, ForeignKey('aircraft_slot.id'), nullable=False)
    origin = Column(String(50), nullable=False)
    destination = Column(String(50), nullable=False)
    miles = Column(Integer, nullable=False)
    selling_airline = Column(String(50), nullable=False)
    operating_airline = Column(String(50), nullable=False)

class Booking(Base):
    __tablename__ = 'booking'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    customer_id = Column(Integer, ForeignKey('customer.id', ondelete='CASCADE'), nullable=False)
    flight_id = Column(Integer, ForeignKey('flight.id'), nullable=False)

class BookingDetails(Base):
    __tablename__ = 'booking_details'
    
    booking_id = Column(Integer, ForeignKey('booking.id', ondelete='CASCADE'), primary_key=True, nullable=False)
    aircraft_id = Column(Integer, nullable=False)
    seat_row = Column(String(50), nullable=False)
    seat_letter = Column(String(1), nullable=False)
    price = Column(Float, nullable=False, check_constraint="price > 0")
    purchase_timestamp = Column(DateTime, nullable=False)
    payment_status = Column(String(50), check_constraint="payment_status IN ('ACCEPTED', 'REJECTED')")
    booking_status = Column(String(50), check_constraint="booking_status IN ('CONFIRMED', 'CANCELLED')")
    last_updated = Column(DateTime, primary_key=True, nullable=False, server_default=text("NOW()"))

    __table_args__ = (
        ForeignKeyConstraint(['aircraft_id', 'seat_row', 'seat_letter'], ['aircraft_seats.aircraft_id', 'aircraft_seats.seat_row', 'aircraft_seats.seat_letter']),
    )

class FlightStatus(Base):
    __tablename__ = 'flight_status'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    flight_id = Column(Integer, ForeignKey('flight.id', ondelete='CASCADE'), nullable=False)
    status = Column(String(50), check_constraint="status IN ('SCHEDULED', 'CANCELLED', 'DELAYED')")
    last_updated = Column(DateTime, nullable=False, server_default=text("NOW()"))

class AircraftCrew(Base):
    __tablename__ = 'aircraft_crew'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    role = Column(String(50), check_constraint="role IN ('PILOT', 'COPILOT', 'STEWARDESS')")

class CrewAssignment(Base):
    __tablename__ = 'crew_assignment'
    
    flight_id = Column(Integer, ForeignKey('flight.id', ondelete='CASCADE'), primary_key=True, nullable=False)
    crew_id = Column(Integer, ForeignKey('aircraft_crew.id', ondelete='CASCADE'), primary_key=True, nullable=False)
    assignment_date = Column(DateTime, nullable=False, server_default=text("NOW()"))

class MaintenanceEvent(Base):
    __tablename__ = 'maintenance_event'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    slot_id = Column(Integer, ForeignKey('aircraft_slot.id', ondelete='CASCADE'), nullable=False)
    is_scheduled = Column(Boolean, nullable=False)
    airport = Column(String(50), nullable=False)

class AircraftSlot(Base):
    __tablename__ = 'aircraft_slot'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    type = Column(String(30), check_constraint="type IN ('FLIGHT', 'MAINTENANCE')")
    aircraft_id = Column(Integer, ForeignKey('aircraft.id', ondelete='CASCADE'), nullable=False)
    start_datetime = Column(DateTime, nullable=False)
    end_datetime = Column(DateTime, nullable=False)

class Reporter(Base):
    __tablename__ = 'reporter'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    reporter_role = Column(String(50), nullable=False, check_constraint="reporter_role IN ('PILOT', 'MAINTENANCE PERSONNEL')")

class WorkOrder(Base):
    __tablename__ = 'work_order'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    maintenance_event_id = Column(Integer, ForeignKey('maintenance_event.id'), nullable=False)
    execution_place = Column(String(50), nullable=False)
    execution_date = Column(Date, nullable=False)
    is_scheduled = Column(Boolean, nullable=False)

class AircraftOOS(Base):
    __tablename__ = 'aircraft_oos'
    
    maintenance_event_id = Column(Integer, ForeignKey('maintenance_event.id', ondelete='CASCADE'), primary_key=True, nullable=False)
    event_subtype = Column(String(50), check_constraint="event_subtype IN ('MAINTENANCE', 'REVISION')")

class OperationalInterruption(Base):
    __tablename__ = 'operational_interruption'
    
    maintenance_event_id = Column(Integer, ForeignKey('maintenance_event.id', ondelete='CASCADE'), primary_key=True, nullable=False)
    flight_id = Column(Integer, ForeignKey('flight.id', ondelete='CASCADE'), nullable=False)
    event_subtype = Column(String(50), check_constraint="event_subtype IN ('DELAY', 'SAFETY')")

class WorkOrderScheduled(Base):
    __tablename__ = 'work_order_scheduled'
    
    work_order_id = Column(Integer, ForeignKey('work_order.id', ondelete='CASCADE'), nullable=False)
    forecasted_date = Column(Date, nullable=False)
    forecasted_man_hours = Column(Integer, nullable=False)
    
    __table_args__ = (PrimaryKeyConstraint('work_order_id', name='pk_work_order_scheduled'),)

class WorkOrderUnscheduled(Base):
    __tablename__ = 'work_order_unscheduled'
    
    work_order_id = Column(Integer, ForeignKey('work_order.id', ondelete='CASCADE'), nullable=False)
    reporter_id = Column(Integer, ForeignKey('reporter.id'), nullable=False)
    due_date = Column(Date, nullable=False)
    reporting_date = Column(Date, nullable=True)
    
    __table_args__ = (PrimaryKeyConstraint('work_order_id', name='pk_work_order_unscheduled'),)

class CustomerPreferences(Base):
    __tablename__ = 'customer_preferences'
    
    customer_id = Column(Integer, ForeignKey('customer.id', ondelete='CASCADE'), primary_key=True, nullable=False)
    preferences = Column(JSONB, nullable=False)

class AircraftMaintenanceLogs(Base):
    __tablename__ = 'aircraft_maintenance_logs'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    aircraft_maintenance_id = Column(Integer, ForeignKey('aircraft.id', ondelete='CASCADE'), nullable=False)
    logs = Column(JSONB, nullable=False)

class CustomerFeedback(Base):
    __tablename__ = 'customer_feedback'
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    customer_id = Column(Integer, ForeignKey('customer.id', ondelete='CASCADE'), nullable=False)
    flight_id = Column(Integer, ForeignKey('flight.id', ondelete='CASCADE'), nullable=False)
    feedback = Column(JSONB, nullable=False)

