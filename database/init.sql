-- Create database
CREATE DATABASE IF NOT EXISTS concert_tickets;
USE concert_tickets;

-- Concerts table
CREATE TABLE IF NOT EXISTS concerts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    venue VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    total_seats INT NOT NULL,
    available_seats INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Seats table - tracks individual seats
CREATE TABLE IF NOT EXISTS seats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    concert_id INT NOT NULL,
    section VARCHAR(50) NOT NULL,
    row_number VARCHAR(10) NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (concert_id) REFERENCES concerts(id) ON DELETE CASCADE,
    UNIQUE KEY unique_seat (concert_id, section, row_number, seat_number)
);

-- Tickets/Bookings table
CREATE TABLE IF NOT EXISTS tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    concert_id INT NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    customer_email VARCHAR(255) NOT NULL,
    customer_phone VARCHAR(20),
    total_price DECIMAL(10, 2) NOT NULL,
    booking_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    booking_status ENUM('confirmed', 'cancelled') DEFAULT 'confirmed',
    FOREIGN KEY (concert_id) REFERENCES concerts(id) ON DELETE CASCADE
);

-- Ticket seats - links tickets to specific seats
CREATE TABLE IF NOT EXISTS ticket_seats (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    seat_id INT NOT NULL,
    FOREIGN KEY (ticket_id) REFERENCES tickets(id) ON DELETE CASCADE,
    FOREIGN KEY (seat_id) REFERENCES seats(id) ON DELETE CASCADE,
    UNIQUE KEY unique_ticket_seat (ticket_id, seat_id)
);

-- Insert sample concerts
INSERT INTO concerts (name, venue, date, time, total_seats, available_seats, price) VALUES
('Rock Night 2025', 'Bangkok Arena', '2025-03-15', '20:00:00', 100, 100, 1500.00),
('Jazz Evening', 'Blue Note Club', '2025-04-20', '19:30:00', 50, 50, 800.00),
('Pop Concert Extravaganza', 'Thunder Dome', '2025-05-10', '18:00:00', 150, 150, 2000.00),
('Classical Symphony', 'Bangkok Concert Hall', '2025-06-05', '19:00:00', 80, 80, 1200.00),
('EDM Festival', 'Central World Plaza', '2025-07-22', '21:00:00', 200, 200, 1800.00);

-- Generate seats for Concert 1: Rock Night (VIP, Regular sections)
-- VIP Section (Rows A-C, Seats 1-10) - 30 seats
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 1, 'VIP', row_letter, seat_num, TRUE
FROM (SELECT 'A' as row_letter UNION SELECT 'B' UNION SELECT 'C') rows
CROSS JOIN (
    SELECT '1' as seat_num UNION SELECT '2' UNION SELECT '3' UNION SELECT '4' UNION SELECT '5'
    UNION SELECT '6' UNION SELECT '7' UNION SELECT '8' UNION SELECT '9' UNION SELECT '10'
) seats;

-- Regular Section (Rows D-J, Seats 1-10) - 70 seats
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 1, 'REGULAR', row_letter, seat_num, TRUE
FROM (
    SELECT 'D' as row_letter UNION SELECT 'E' UNION SELECT 'F' UNION SELECT 'G'
    UNION SELECT 'H' UNION SELECT 'I' UNION SELECT 'J'
) rows
CROSS JOIN (
    SELECT '1' as seat_num UNION SELECT '2' UNION SELECT '3' UNION SELECT '4' UNION SELECT '5'
    UNION SELECT '6' UNION SELECT '7' UNION SELECT '8' UNION SELECT '9' UNION SELECT '10'
) seats;

-- Generate seats for Concert 2: Jazz Evening (Front, Back sections)
-- Front Section (Rows A-B, Seats 1-10) - 20 seats
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 2, 'FRONT', row_letter, seat_num, TRUE
FROM (SELECT 'A' as row_letter UNION SELECT 'B') rows
CROSS JOIN (
    SELECT '1' as seat_num UNION SELECT '2' UNION SELECT '3' UNION SELECT '4' UNION SELECT '5'
    UNION SELECT '6' UNION SELECT '7' UNION SELECT '8' UNION SELECT '9' UNION SELECT '10'
) seats;

-- Back Section (Rows C-E, Seats 1-10) - 30 seats
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 2, 'BACK', row_letter, seat_num, TRUE
FROM (SELECT 'C' as row_letter UNION SELECT 'D' UNION SELECT 'E') rows
CROSS JOIN (
    SELECT '1' as seat_num UNION SELECT '2' UNION SELECT '3' UNION SELECT '4' UNION SELECT '5'
    UNION SELECT '6' UNION SELECT '7' UNION SELECT '8' UNION SELECT '9' UNION SELECT '10'
) seats;

-- Generate seats for Concert 3: Pop Concert (VIP, Regular, Standing sections)
-- VIP Section - 30 seats
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 3, 'VIP', row_letter, seat_num, TRUE
FROM (SELECT 'A' as row_letter UNION SELECT 'B' UNION SELECT 'C') rows
CROSS JOIN (
    SELECT '1' as seat_num UNION SELECT '2' UNION SELECT '3' UNION SELECT '4' UNION SELECT '5'
    UNION SELECT '6' UNION SELECT '7' UNION SELECT '8' UNION SELECT '9' UNION SELECT '10'
) seats;

-- Regular Section - 70 seats
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 3, 'REGULAR', row_letter, seat_num, TRUE
FROM (
    SELECT 'D' as row_letter UNION SELECT 'E' UNION SELECT 'F' UNION SELECT 'G'
    UNION SELECT 'H' UNION SELECT 'I' UNION SELECT 'J'
) rows
CROSS JOIN (
    SELECT '1' as seat_num UNION SELECT '2' UNION SELECT '3' UNION SELECT '4' UNION SELECT '5'
    UNION SELECT '6' UNION SELECT '7' UNION SELECT '8' UNION SELECT '9' UNION SELECT '10'
) seats;

-- Standing Section - 50 "seats"
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 3, 'STANDING', 'S', LPAD(num, 3, '0'), TRUE
FROM (
    SELECT 1 as num UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
    UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9 UNION SELECT 10
    UNION SELECT 11 UNION SELECT 12 UNION SELECT 13 UNION SELECT 14 UNION SELECT 15
    UNION SELECT 16 UNION SELECT 17 UNION SELECT 18 UNION SELECT 19 UNION SELECT 20
    UNION SELECT 21 UNION SELECT 22 UNION SELECT 23 UNION SELECT 24 UNION SELECT 25
    UNION SELECT 26 UNION SELECT 27 UNION SELECT 28 UNION SELECT 29 UNION SELECT 30
    UNION SELECT 31 UNION SELECT 32 UNION SELECT 33 UNION SELECT 34 UNION SELECT 35
    UNION SELECT 36 UNION SELECT 37 UNION SELECT 38 UNION SELECT 39 UNION SELECT 40
    UNION SELECT 41 UNION SELECT 42 UNION SELECT 43 UNION SELECT 44 UNION SELECT 45
    UNION SELECT 46 UNION SELECT 47 UNION SELECT 48 UNION SELECT 49 UNION SELECT 50
) numbers;

-- Generate seats for Concert 4: Classical Symphony
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 4, 'ORCHESTRA', row_letter, seat_num, TRUE
FROM (
    SELECT 'A' as row_letter UNION SELECT 'B' UNION SELECT 'C' UNION SELECT 'D'
    UNION SELECT 'E' UNION SELECT 'F' UNION SELECT 'G' UNION SELECT 'H'
) rows
CROSS JOIN (
    SELECT '1' as seat_num UNION SELECT '2' UNION SELECT '3' UNION SELECT '4' UNION SELECT '5'
    UNION SELECT '6' UNION SELECT '7' UNION SELECT '8' UNION SELECT '9' UNION SELECT '10'
) seats;

-- Generate seats for Concert 5: EDM Festival
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 5, 'GENERAL', row_letter, seat_num, TRUE
FROM (
    SELECT 'A' as row_letter UNION SELECT 'B' UNION SELECT 'C' UNION SELECT 'D'
    UNION SELECT 'E' UNION SELECT 'F' UNION SELECT 'G' UNION SELECT 'H'
    UNION SELECT 'I' UNION SELECT 'J' UNION SELECT 'K' UNION SELECT 'L'
    UNION SELECT 'M' UNION SELECT 'N' UNION SELECT 'O' UNION SELECT 'P'
    UNION SELECT 'Q' UNION SELECT 'R' UNION SELECT 'S' UNION SELECT 'T'
) rows
CROSS JOIN (
    SELECT '1' as seat_num UNION SELECT '2' UNION SELECT '3' UNION SELECT '4' UNION SELECT '5'
    UNION SELECT '6' UNION SELECT '7' UNION SELECT '8' UNION SELECT '9' UNION SELECT '10'
) seats;

-- Insert sample bookings
-- Booking 1: Rock Night - 2 VIP seats
INSERT INTO tickets (concert_id, customer_name, customer_email, customer_phone, total_price, booking_status)
VALUES (1, 'John Doe', 'john@example.com', '0812345678', 3000.00, 'confirmed');

SET @ticket1_id = LAST_INSERT_ID();

INSERT INTO ticket_seats (ticket_id, seat_id)
SELECT @ticket1_id, id FROM seats WHERE concert_id = 1 AND section = 'VIP' AND row_number = 'A' AND seat_number IN ('1', '2');

UPDATE seats SET is_available = FALSE WHERE concert_id = 1 AND section = 'VIP' AND row_number = 'A' AND seat_number IN ('1', '2');

-- Booking 2: Jazz Evening - 1 Front seat
INSERT INTO tickets (concert_id, customer_name, customer_email, customer_phone, total_price, booking_status)
VALUES (2, 'Jane Smith', 'jane@example.com', '0823456789', 800.00, 'confirmed');

SET @ticket2_id = LAST_INSERT_ID();

INSERT INTO ticket_seats (ticket_id, seat_id)
SELECT @ticket2_id, id FROM seats WHERE concert_id = 2 AND section = 'FRONT' AND row_number = 'A' AND seat_number = '5' LIMIT 1;

UPDATE seats SET is_available = FALSE WHERE concert_id = 2 AND section = 'FRONT' AND row_number = 'A' AND seat_number = '5';

-- Booking 3: Rock Night - 4 Regular seats
INSERT INTO tickets (concert_id, customer_name, customer_email, customer_phone, total_price, booking_status)
VALUES (1, 'Bob Wilson', 'bob@example.com', '0834567890', 6000.00, 'confirmed');

SET @ticket3_id = LAST_INSERT_ID();

INSERT INTO ticket_seats (ticket_id, seat_id)
SELECT @ticket3_id, id FROM seats WHERE concert_id = 1 AND section = 'REGULAR' AND row_number = 'D' AND seat_number IN ('3', '4', '5', '6');

UPDATE seats SET is_available = FALSE WHERE concert_id = 1 AND section = 'REGULAR' AND row_number = 'D' AND seat_number IN ('3', '4', '5', '6');

-- Update available seat counts
UPDATE concerts c 
SET available_seats = (
    SELECT COUNT(*) FROM seats s 
    WHERE s.concert_id = c.id AND s.is_available = TRUE
);