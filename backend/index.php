<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

// Database connection
$host = getenv('DB_HOST') ?: 'db';
$dbname = getenv('DB_NAME') ?: 'concert_tickets';
$username = getenv('DB_USER') ?: 'root';
$password = getenv('DB_PASSWORD') ?: 'rootpassword';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}

$method = $_SERVER['REQUEST_METHOD'];
$request = explode('/', trim($_SERVER['PATH_INFO'] ?? '', '/'));
$resource = $request[0] ?? '';

// Router
switch ($resource) {
    case 'concerts':
        handleConcerts($pdo, $method, $request);
        break;
    case 'seats':
        handleSeats($pdo, $method, $request);
        break;
    case 'tickets':
        handleTickets($pdo, $method, $request);
        break;
    case 'health':
        echo json_encode(['status' => 'healthy', 'timestamp' => date('Y-m-d H:i:s')]);
        break;
    default:
        echo json_encode(['error' => 'Invalid endpoint']);
        break;
}

// Concert handlers
function handleConcerts($pdo, $method, $request) {
    switch ($method) {
        case 'GET':
            if (isset($request[1])) {
                // Get single concert with seat statistics
                $stmt = $pdo->prepare("
                    SELECT c.*, 
                           (SELECT COUNT(*) FROM seats WHERE concert_id = c.id) as total_seats,
                           (SELECT COUNT(*) FROM seats WHERE concert_id = c.id AND is_available = TRUE) as available_seats,
                           (SELECT COUNT(DISTINCT section) FROM seats WHERE concert_id = c.id) as sections_count
                    FROM concerts c 
                    WHERE c.id = ?
                ");
                $stmt->execute([$request[1]]);
                $concert = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if ($concert) {
                    // Get section breakdown
                    $stmt = $pdo->prepare("
                        SELECT section, 
                               COUNT(*) as total,
                               SUM(CASE WHEN is_available = TRUE THEN 1 ELSE 0 END) as available
                        FROM seats 
                        WHERE concert_id = ? 
                        GROUP BY section
                    ");
                    $stmt->execute([$request[1]]);
                    $concert['sections'] = $stmt->fetchAll(PDO::FETCH_ASSOC);
                }
                
                echo json_encode($concert ?: ['error' => 'Concert not found']);
            } else {
                // Get all concerts with seat counts
                $stmt = $pdo->query("
                    SELECT c.*, 
                           (SELECT COUNT(*) FROM seats WHERE concert_id = c.id) as total_seats,
                           (SELECT COUNT(*) FROM seats WHERE concert_id = c.id AND is_available = TRUE) as available_seats
                    FROM concerts c 
                    ORDER BY c.date ASC
                ");
                echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
            }
            break;
        case 'POST':
            $data = json_decode(file_get_contents('php://input'), true);
            $stmt = $pdo->prepare("INSERT INTO concerts (name, venue, date, time, total_seats, available_seats, price) VALUES (?, ?, ?, ?, ?, ?, ?)");
            $stmt->execute([
                $data['name'], $data['venue'], $data['date'], $data['time'],
                $data['total_seats'], $data['total_seats'], $data['price']
            ]);
            echo json_encode(['success' => true, 'id' => $pdo->lastInsertId()]);
            break;
        default:
            echo json_encode(['error' => 'Method not allowed']);
    }
}

// Seat handlers
function handleSeats($pdo, $method, $request) {
    switch ($method) {
        case 'GET':
            if (isset($request[1]) && $request[1] === 'concert') {
                $concertId = $request[2] ?? null;
                
                if (isset($request[3]) && $request[3] === 'section') {
                    // Get seats for specific section
                    $section = $_GET['section'] ?? null;
                    $stmt = $pdo->prepare("
                        SELECT * FROM seats 
                        WHERE concert_id = ? AND section = ? 
                        ORDER BY row_number, CAST(seat_number AS UNSIGNED)
                    ");
                    $stmt->execute([$concertId, $section]);
                } else {
                    // Get all seats for concert grouped by section
                    $stmt = $pdo->prepare("
                        SELECT * FROM seats 
                        WHERE concert_id = ? 
                        ORDER BY section, row_number, CAST(seat_number AS UNSIGNED)
                    ");
                    $stmt->execute([$concertId]);
                }
                
                $seats = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                // Group by section and row
                $grouped = [];
                foreach ($seats as $seat) {
                    $section = $seat['section'];
                    $row = $seat['row_number'];
                    if (!isset($grouped[$section])) {
                        $grouped[$section] = [];
                    }
                    if (!isset($grouped[$section][$row])) {
                        $grouped[$section][$row] = [];
                    }
                    $grouped[$section][$row][] = $seat;
                }
                
                echo json_encode($grouped);
            } else {
                echo json_encode(['error' => 'Concert ID required']);
            }
            break;
        default:
            echo json_encode(['error' => 'Method not allowed']);
    }
}

// Ticket handlers
function handleTickets($pdo, $method, $request) {
    switch ($method) {
        case 'GET':
            if (isset($request[1]) && $request[1] === 'concert') {
                // Get tickets for specific concert with seat details
                $concertId = $request[2] ?? null;
                $stmt = $pdo->prepare("
                    SELECT t.*, c.name as concert_name,
                           GROUP_CONCAT(CONCAT(s.section, '-', s.row_number, s.seat_number) SEPARATOR ', ') as seats
                    FROM tickets t 
                    JOIN concerts c ON t.concert_id = c.id
                    LEFT JOIN ticket_seats ts ON t.id = ts.ticket_id
                    LEFT JOIN seats s ON ts.seat_id = s.id
                    WHERE t.concert_id = ? 
                    GROUP BY t.id
                    ORDER BY t.booking_date DESC
                ");
                $stmt->execute([$concertId]);
                echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
            } else if (isset($request[1])) {
                // Get single ticket with seat details
                $stmt = $pdo->prepare("
                    SELECT t.*, c.name as concert_name, c.venue, c.date, c.time,
                           GROUP_CONCAT(CONCAT(s.section, '-', s.row_number, s.seat_number) SEPARATOR ', ') as seats
                    FROM tickets t 
                    JOIN concerts c ON t.concert_id = c.id
                    LEFT JOIN ticket_seats ts ON t.id = ts.ticket_id
                    LEFT JOIN seats s ON ts.seat_id = s.id
                    WHERE t.id = ?
                    GROUP BY t.id
                ");
                $stmt->execute([$request[1]]);
                echo json_encode($stmt->fetch(PDO::FETCH_ASSOC));
            } else {
                // Get all tickets with seat details
                $stmt = $pdo->query("
                    SELECT t.*, c.name as concert_name,
                           GROUP_CONCAT(CONCAT(s.section, '-', s.row_number, s.seat_number) SEPARATOR ', ') as seats
                    FROM tickets t 
                    JOIN concerts c ON t.concert_id = c.id
                    LEFT JOIN ticket_seats ts ON t.id = ts.ticket_id
                    LEFT JOIN seats s ON ts.seat_id = s.id
                    GROUP BY t.id
                    ORDER BY t.booking_date DESC
                ");
                echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
            }
            break;
        case 'POST':
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Validate seat IDs
            if (empty($data['seat_ids']) || !is_array($data['seat_ids'])) {
                echo json_encode(['error' => 'Please select at least one seat']);
                break;
            }
            
            $pdo->beginTransaction();
            try {
                // Check if all seats are available
                $placeholders = str_repeat('?,', count($data['seat_ids']) - 1) . '?';
                $stmt = $pdo->prepare("
                    SELECT id, is_available, section, row_number, seat_number 
                    FROM seats 
                    WHERE id IN ($placeholders) AND concert_id = ?
                ");
                $params = array_merge($data['seat_ids'], [$data['concert_id']]);
                $stmt->execute($params);
                $seats = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                if (count($seats) !== count($data['seat_ids'])) {
                    throw new Exception('Some seats are invalid');
                }
                
                foreach ($seats as $seat) {
                    if (!$seat['is_available']) {
                        throw new Exception("Seat {$seat['section']}-{$seat['row_number']}{$seat['seat_number']} is no longer available");
                    }
                }
                
                // Get concert price
                $stmt = $pdo->prepare("SELECT price FROM concerts WHERE id = ?");
                $stmt->execute([$data['concert_id']]);
                $concert = $stmt->fetch(PDO::FETCH_ASSOC);
                $totalPrice = $concert['price'] * count($data['seat_ids']);
                
                // Create ticket
                $stmt = $pdo->prepare("
                    INSERT INTO tickets (concert_id, customer_name, customer_email, customer_phone, total_price, booking_status) 
                    VALUES (?, ?, ?, ?, ?, 'confirmed')
                ");
                $stmt->execute([
                    $data['concert_id'], 
                    $data['customer_name'], 
                    $data['customer_email'],
                    $data['customer_phone'] ?? null,
                    $totalPrice
                ]);
                
                $ticketId = $pdo->lastInsertId();
                
                // Link seats to ticket
                $stmt = $pdo->prepare("INSERT INTO ticket_seats (ticket_id, seat_id) VALUES (?, ?)");
                foreach ($data['seat_ids'] as $seatId) {
                    $stmt->execute([$ticketId, $seatId]);
                }
                
                // Mark seats as unavailable
                $stmt = $pdo->prepare("UPDATE seats SET is_available = FALSE WHERE id IN ($placeholders)");
                $stmt->execute($data['seat_ids']);
                
                // Update concert available seats count
                $stmt = $pdo->prepare("
                    UPDATE concerts 
                    SET available_seats = (SELECT COUNT(*) FROM seats WHERE concert_id = ? AND is_available = TRUE)
                    WHERE id = ?
                ");
                $stmt->execute([$data['concert_id'], $data['concert_id']]);
                
                $pdo->commit();
                
                echo json_encode([
                    'success' => true, 
                    'ticket_id' => $ticketId, 
                    'total_price' => $totalPrice,
                    'seat_count' => count($data['seat_ids'])
                ]);
            } catch (Exception $e) {
                $pdo->rollBack();
                echo json_encode(['error' => $e->getMessage()]);
            }
            break;
        default:
            echo json_encode(['error' => 'Method not allowed']);
    }
}
?>