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
    row_label VARCHAR(10) NOT NULL,
    seat_number VARCHAR(10) NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (concert_id) REFERENCES concerts(id) ON DELETE CASCADE,
    UNIQUE KEY unique_seat (concert_id, section, row_label, seat_number)
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
('Pop Concert Extravaganza', 'Thunder Dome', '2025-05-10', '18:00:00', 80, 80, 2000.00),
('Classical Symphony', 'Bangkok Concert Hall', '2025-06-05', '19:00:00', 60, 60, 1200.00),
('EDM Festival', 'Central World Plaza', '2025-07-22', '21:00:00', 100, 100, 1800.00);

-- Generate seats for Concert 1: Rock Night (100 seats: 30 VIP + 70 Regular)
INSERT INTO seats (concert_id, section, row_label, seat_number, is_available)
SELECT 1, 'VIP', row_letter, seat_num, TRUE
FROM (
    SELECT 'A' as row_letter UNION ALL SELECT 'B' UNION ALL SELECT 'C'
) r
CROSS JOIN (
    SELECT '1' as seat_num UNION ALL SELECT '2' UNION ALL SELECT '3' UNION ALL SELECT '4' UNION ALL SELECT '5'
    UNION ALL SELECT '6' UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10'
) s;

INSERT INTO seats (concert_id, section, row_label, seat_number, is_available)
SELECT 1, 'REGULAR', row_letter, seat_num, TRUE
FROM (
    SELECT 'D' as row_letter UNION ALL SELECT 'E' UNION ALL SELECT 'F' UNION ALL SELECT 'G'
    UNION ALL SELECT 'H' UNION ALL SELECT 'I' UNION ALL SELECT 'J'
) r
CROSS JOIN (
    SELECT '1' as seat_num UNION ALL SELECT '2' UNION ALL SELECT '3' UNION ALL SELECT '4' UNION ALL SELECT '5'
    UNION ALL SELECT '6' UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10'
) s;

-- Generate seats for Concert 2: Jazz Evening (50 seats: 20 Front + 30 Back)
INSERT INTO seats (concert_id, section, row_label, seat_number, is_available)
SELECT 2, 'FRONT', row_letter, seat_num, TRUE
FROM (
    SELECT 'A' as row_letter UNION ALL SELECT 'B'
) r
CROSS JOIN (
    SELECT '1' as seat_num UNION ALL SELECT '2' UNION ALL SELECT '3' UNION ALL SELECT '4' UNION ALL SELECT '5'
    UNION ALL SELECT '6' UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10'
) s;

INSERT INTO seats (concert_id, section, row_label, seat_number, is_available)
SELECT 2, 'BACK', row_letter, seat_num, TRUE
FROM (
    SELECT 'C' as row_letter UNION ALL SELECT 'D' UNION ALL SELECT 'E'
) r
CROSS JOIN (
    SELECT '1' as seat_num UNION ALL SELECT '2' UNION ALL SELECT '3' UNION ALL SELECT '4' UNION ALL SELECT '5'
    UNION ALL SELECT '6' UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10'
) s;

-- Generate seats for Concert 3: Pop Concert (80 seats: 20 VIP + 60 Regular)
INSERT INTO seats (concert_id, section, row_label, seat_number, is_available)
SELECT 3, 'VIP', row_letter, seat_num, TRUE
FROM (
    SELECT 'A' as row_letter UNION ALL SELECT 'B'
) r
CROSS JOIN (
    SELECT '1' as seat_num UNION ALL SELECT '2' UNION ALL SELECT '3' UNION ALL SELECT '4' UNION ALL SELECT '5'
    UNION ALL SELECT '6' UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10'
) s;

INSERT INTO seats (concert_id, section, row_label, seat_number, is_available)
SELECT 3, 'REGULAR', row_letter, seat_num, TRUE
FROM (
    SELECT 'C' as row_letter UNION ALL SELECT 'D' UNION ALL SELECT 'E' UNION ALL SELECT 'F'
    UNION ALL SELECT 'G' UNION ALL SELECT 'H'
) r
CROSS JOIN (
    SELECT '1' as seat_num UNION ALL SELECT '2' UNION ALL SELECT '3' UNION ALL SELECT '4' UNION ALL SELECT '5'
    UNION ALL SELECT '6' UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10'
) s;

-- Generate seats for Concert 4: Classical Symphony (60 seats in Orchestra section)
INSERT INTO seats (concert_id, section, row_label, seat_number, is_available)
SELECT 4, 'ORCHESTRA', row_letter, seat_num, TRUE
FROM (
    SELECT 'A' as row_letter UNION ALL SELECT 'B' UNION ALL SELECT 'C' UNION ALL SELECT 'D'
    UNION ALL SELECT 'E' UNION ALL SELECT 'F'
) r
CROSS JOIN (
    SELECT '1' as seat_num UNION ALL SELECT '2' UNION ALL SELECT '3' UNION ALL SELECT '4' UNION ALL SELECT '5'
    UNION ALL SELECT '6' UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10'
) s;

-- Generate seats for Concert 5: EDM Festival (100 seats in General section)
INSERT INTO seats (concert_id, section, row_label, seat_number, is_available)
SELECT 5, 'GENERAL', row_letter, seat_num, TRUE
FROM (
    SELECT 'A' as row_letter UNION ALL SELECT 'B' UNION ALL SELECT 'C' UNION ALL SELECT 'D' UNION ALL SELECT 'E'
    UNION ALL SELECT 'F' UNION ALL SELECT 'G' UNION ALL SELECT 'H' UNION ALL SELECT 'I' UNION ALL SELECT 'J'
) r
CROSS JOIN (
    SELECT '1' as seat_num UNION ALL SELECT '2' UNION ALL SELECT '3' UNION ALL SELECT '4' UNION ALL SELECT '5'
    UNION ALL SELECT '6' UNION ALL SELECT '7' UNION ALL SELECT '8' UNION ALL SELECT '9' UNION ALL SELECT '10'
) s;

-- Insert sample bookings
INSERT INTO tickets (concert_id, customer_name, customer_email, customer_phone, total_price, booking_status)
VALUES (1, 'John Doe', 'john@example.com', '0812345678', 3000.00, 'confirmed');
SET @ticket1_id = LAST_INSERT_ID();

INSERT INTO ticket_seats (ticket_id, seat_id)
SELECT @ticket1_id, id FROM seats WHERE concert_id = 1 AND section = 'VIP' AND row_label = 'A' AND seat_number IN ('1', '2');

UPDATE seats SET is_available = FALSE WHERE concert_id = 1 AND section = 'VIP' AND row_label = 'A' AND seat_number IN ('1', '2');

-- Booking 2
INSERT INTO tickets (concert_id, customer_name, customer_email, customer_phone, total_price, booking_status)
VALUES (2, 'Jane Smith', 'jane@example.com', '0823456789', 800.00, 'confirmed');
SET @ticket2_id = LAST_INSERT_ID();

INSERT INTO ticket_seats (ticket_id, seat_id)
SELECT @ticket2_id, id FROM seats WHERE concert_id = 2 AND section = 'FRONT' AND row_label = 'A' AND seat_number = '5' LIMIT 1;

UPDATE seats SET is_available = FALSE WHERE concert_id = 2 AND section = 'FRONT' AND row_label = 'A' AND seat_number = '5';

-- Update available seat counts
UPDATE concerts c 
SET available_seats = (
    SELECT COUNT(*) FROM seats s 
    WHERE s.concert_id = c.id AND s.is_available = TRUE
);