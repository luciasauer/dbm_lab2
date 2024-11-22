--Find flights departing in the next 7 days that are operated by a specific aircraft model but are not yet fully booked.

--Retrieve the flight for the next 7 days
with next_flight as (
select
f.id as flight_id,
aslots.aircraft_id as aircraft_id
--aslots.id as slot_id,
--aslots.start_datetime as departure_time,
from
flight f
join aircraft_slot aslots on aslots.id = f.slot_id
join flight_status fs on fs.flight_id = f.id
where aslots.type = 'FLIGHT' 
and aslots.start_datetime>CURRENT_TIMESTAMP 
and aslots.start_datetime>CURRENT_TIMESTAMP + INTERVAL '7 days'
and fs.last_updated = (select MAX(last_updated) from flight_status fs2 where fs2.flight_id = fs.flight_id)
and fs.status <> 'CANCELLED'
)
, 

--Calculates the number of confirmed passengers for each flight
passagners as (
select 
f.id as flight_id,
aslots.aircraft_id,
count(distinct b.id) as number_passangers
from booking b
join flight f on f.id = b.flight_id
join flight_status fs on fs.flight_id = f.id
join booking_details bd on bd.booking_id = b.id
join aircraft_slot aslots on aslots.id = f.slot_id
where bd.last_updated = (select MAX(last_updated) from booking_details bd2 where bd2.booking_id = bd.booking_id)
and bd.payment_status = 'ACCEPTED' and bd.booking_status = 'CONFIRMED'
and fs.last_updated = (select MAX(last_updated) from flight_status fs2 where fs2.flight_id = fs.flight_id)
and aslots.type = 'FLIGHT'
group by 1,2)

--number of seats by aircraft

, capacity as (
select a.id as aircraft_id,
COUNT(DISTINCT CONCAT(as2.seat_row, '-', as2.seat_letter, '-', as2.seat_type)) AS capacity_number
from 
aircraft a
join aircraft_seats as2 on a.id= as2.aircraft_id
group by 1)

--Join the tables to get the the flights in the next 7 days that are not fully booked operated by a specific aircraft

select 
nf.flight_id,
nf.aircraft_id,
p.number_passangers,
c.capacity_number,
c.capacity_number- p.number_passangers number_available_seats
from next_flight nf
join passagners p on nf.flight_id = p.flight_id and nf.aircraft_id = p.aircraft_id
join capacity c on c.aircraft_id = p.aircraft_id
where nf.flight_id is not null --this guarantee that we are only retrieving for the flight on the next 7 days
and c.capacity_number- p.number_passangers>0 --not fully booked












