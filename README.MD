#  Concert Ticket Management System(Jampass)

A full-stack web application for managing concert tickets with visual seat selection, real-time availability tracking, and CI/CD automation using Jenkins and Docker.

## Features

### Core Features
- **Browse Concerts**: View all available concerts with venue details and pricing
- **Visual Seat Selection**: Interactive seat map with real-time availability
- **Smart Booking System**: 
  - Select specific seats from visual seat map
  - Multiple sections per venue (VIP, Regular, Front, Back, etc.)
  - Row and seat number tracking
  - Real-time seat availability updates
- **View Bookings**: Track all ticket purchases with exact seat assignments
- **RESTful API**: Complete backend API for all operations
- **Database Transaction Safety**: Ensures no double-booking with SQL transactions

### Technical Features
- Responsive design with modern UI/UX
- Color-coded seat status (Available/Selected/Taken)
- Form validation and error handling
- Health check endpoints
- Containerized with Docker
- Automated CI/CD pipeline with Jenkins

## Technology Stack

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Backend**: PHP 8.2 with PDO (MySQL driver)
- **Database**: MySQL 8.0
- **Containerization**: Docker & Docker Compose
- **CI/CD**: Jenkins Pipeline
- **Web Servers**: 
  - Apache 2.4 (Backend)
  - Nginx (Frontend)

## Project Structure

```
concert-ticket-system/
├── backend/
│   ├── index.php              # REST API with seat management
│   └── Dockerfile             # PHP Apache container config
├── frontend/
│   ├── index.html             # Interactive seat selection UI
│   ├── nginx.conf             # Nginx configuration
│   └── Dockerfile             # Frontend container config
├── database/
│   └── init.sql               # Database schema with seats & seed data
├── docker-compose.yml         # Multi-container orchestration
├── Jenkinsfile                # CI/CD pipeline configuration
├── .env.example               # Environment variables template
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

##  Database Schema

### Tables Overview

#### 1. **concerts**
Stores concert information
- `id`, `name`, `venue`, `date`, `time`
- `total_seats`, `available_seats`, `price`
- `created_at`

#### 2. **seats**
Individual seat tracking (100+ seats per concert)
- `id`, `concert_id` (FK)
- `section` (VIP, REGULAR, FRONT, BACK, etc.)
- `row_number` (A, B, C, etc.)
- `seat_number` (1, 2, 3, etc.)
- `is_available` (TRUE/FALSE)
- **Unique constraint**: (concert_id, section, row_number, seat_number)

#### 3. **tickets**
Customer bookings
- `id`, `concert_id` (FK)
- `customer_name`, `customer_email`, `customer_phone`
- `total_price`, `booking_date`, `booking_status`

#### 4. **ticket_seats**
Links tickets to specific seats (many-to-many)
- `id`, `ticket_id` (FK), `seat_id` (FK)

### Sample Data
- 5 concerts with different venues and dates
- 100-200 seats per concert organized in sections
- Multiple seating sections (VIP, Regular, Front, Back, Orchestra, Standing, General)
- 3 pre-booked sample tickets with specific seat assignments

##  Quick Start

### Prerequisites

Make sure you have installed:
- **Docker Desktop** for Windows ([Download](https://www.docker.com/products/docker-desktop))
- **Git** for Windows ([Download](https://git-scm.com/download/win))
- **Jenkins** ([Download](https://www.jenkins.io/download/))

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd concert-ticket-system
   ```

2. **Set up environment variables**
   ```bash
   # Windows Command Prompt
   copy .env.example .env

   # Windows PowerShell
   Copy-Item .env.example .env

   # Git Bash / Linux / Mac
   cp .env.example .env
   ```

3. **Start Docker Desktop**
   - Open Docker Desktop
   - Wait until it shows "Docker Desktop is running"

4. **Build and run with Docker Compose**
   ```bash
   docker compose up -d
   ```

5. **Wait for services to initialize** (about 30 seconds)
   ```bash
   # Check if all services are running
   docker compose ps

   # View logs
   docker compose logs -f
   ```

6. **Access the application**
   - **Frontend (Web UI)**: http://localhost:3000
   - **Backend API**: http://localhost:8000
   - **Database**: localhost:3307 (MySQL client)

## API Endpoints

### Concerts
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/concerts` | Get all concerts with seat statistics |
| GET | `/concerts/{id}` | Get specific concert with section breakdown |
| POST | `/concerts` | Create new concert |

### Seats
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/seats/concert/{id}` | Get all seats for a concert (grouped by section/row) |
| GET | `/seats/concert/{id}/section?section=VIP` | Get seats for specific section |

### Tickets
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tickets` | Get all bookings with seat details |
| GET | `/tickets/{id}` | Get specific booking |
| GET | `/tickets/concert/{id}` | Get all bookings for a concert |
| POST | `/tickets` | Book tickets with seat selection |

### Health Check
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | API health status |

### POST /tickets Request Example
```json
{
  "concert_id": 1,
  "customer_name": "John Doe",
  "customer_email": "john@example.com",
  "customer_phone": "0812345678",
  "seat_ids": [15, 16, 17]
}
```

### Response Example
```json
{
  "success": true,
  "ticket_id": 4,
  "total_price": 4500.00,
  "seat_count": 3
}
```

## CI/CD Pipeline

### Jenkins Pipeline Stages

1. **Checkout** - Pull latest code from repository
2. **Environment Check** - Verify Docker installation
3. **Stop Old Containers** - Clean up previous deployment
4. **Build** - Build Docker images for all services
5. **Deploy** - Start services with docker-compose
6. **Health Check** - Verify backend API is responding
7. **Verify Deployment** - Check all containers are running

### Auto-Trigger Setup
The pipeline is configured to automatically trigger on code commits using:
- **Poll SCM**: Checks repository every 5 minutes
- Alternative: GitHub webhook for instant triggers

### Pipeline Configuration
```groovy
// Jenkinsfile uses Windows batch commands
environment {
    COMPOSE_PROJECT_NAME = 'concert-tickets'
}
```

## Testing

### Manual API Testing

```bash
# Health check
curl http://localhost:8000/health

# Get all concerts
curl http://localhost:8000/concerts

# Get concert with ID 1
curl http://localhost:8000/concerts/1

# Get seats for concert 1
curl http://localhost:8000/seats/concert/1

# Get all bookings
curl http://localhost:8000/tickets
```

### Testing Seat Selection

1. Open http://localhost:3000
2. Click "Select Seats" on any concert
3. Visual seat map will display:
   - **White seats** = Available
   - **Green seats** = Your selection
   - **Gray seats** = Already booked
4. Click seats to select/deselect
5. Fill customer details and confirm

### Database Testing

Access database directly:
```bash
# Using Docker
docker exec -it concert_db mysql -uroot -prootpassword concert_tickets

# Run queries
SELECT * FROM concerts;
SELECT * FROM seats WHERE concert_id = 1;
SELECT * FROM tickets;
```

Or use phpMyAdmin if you have XAMPP running.

## Useful Commands

### Docker Commands
```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs (all services)
docker compose logs

# View logs (specific service)
docker compose logs backend
docker compose logs frontend
docker compose logs db

# Rebuild containers
docker compose up -d --build

# Remove all containers and volumes
docker compose down -v
```

### Troubleshooting Commands
```bash
# Check running containers
docker ps

# Check container status
docker compose ps

# Restart a specific service
docker compose restart backend

# Access backend container shell
docker exec -it concert_backend bash

# Access database container
docker exec -it concert_db mysql -uroot -prootpassword
```

## Environment Variables

Create a `.env` file (copy from `.env.example`):

**Important**: Never commit `.env` file to Git (already in `.gitignore`)

## Key Features to Highlight

1. **Advanced Database Design**
   - 4 normalized tables with foreign key relationships
   - Individual seat tracking system
   - Transaction safety (no double-booking)

2. **Professional UI/UX**
   - Interactive seat map
   - Real-time updates
   - Responsive design
   - Visual feedback (color coding)

3. **Robust Backend**
   - RESTful API architecture
   - Input validation
   - Error handling
   - Health monitoring

4. **DevOps Best Practices**
   - Multi-stage CI/CD pipeline
   - Containerization with Docker
   - Environment variable management
   - Automated testing and deployment

##  Common Issues & Solutions

### Issue: Port Already in Use
```bash
# Find process using port 3000
netstat -ano | findstr :3000

# Kill the process (Windows)
taskkill /PID <PID_NUMBER> /F

# Or change port in docker-compose.yml
ports:
  - "3001:80"  # Use 3001 instead
```

### Issue: Database Connection Failed
```bash
# Wait 30 seconds after starting
# Check database health
docker compose logs db

# Restart database
docker compose restart db
```

### Issue: Seats Not Loading
```bash
# Check backend logs
docker compose logs backend

# Verify database has seed data
docker exec -it concert_db mysql -uroot -prootpassword -e "USE concert_tickets; SELECT COUNT(*) FROM seats;"
```

### Issue: Jenkins Can't Find Docker
Add to Jenkinsfile:
```groovy
environment {
    PATH = "C:\\Program Files\\Docker\\Docker\\resources\\bin;${env.PATH}"
}
```

## Project Statistics

- **Total Lines of Code**: ~1,200+
- **Database Tables**: 4
- **API Endpoints**: 10+
- **Sample Seats**: 500+
- **Docker Containers**: 3
- **Jenkins Pipeline Stages**: 7

## Development

### Adding New Concerts
Modify `database/init.sql` to add more concerts with seats:
```sql
-- Add concert
INSERT INTO concerts (...) VALUES (...);

-- Generate seats
INSERT INTO seats (concert_id, section, row_number, seat_number, is_available)
SELECT 6, 'VIP', row_letter, seat_num, TRUE
FROM (SELECT 'A' as row_letter ...) rows
CROSS JOIN (SELECT '1' as seat_num ...) seats;
```

### Customizing Seat Layouts
Edit the seat generation queries in `init.sql` to create different layouts:
- Change section names
- Modify row letters (A-Z)
- Adjust seat numbers per row
- Add more or fewer sections

## Learning Outcomes

This project demonstrates:
-  Full-stack web development (Frontend + Backend + Database)
-  RESTful API design and implementation
-  Database normalization and relationships
-  Docker containerization and orchestration
-  CI/CD pipeline creation with Jenkins
-  Git version control
-  Environment configuration management
-  SQL transactions and data integrity
-  Interactive UI development
-  Error handling and validation

## License

This project is created for **DIT312 - Final Mini Project** educational purposes.

---

## Support

If you encounter any issues:
1. Check the **Common Issues & Solutions** section above
2. Review `docker compose logs` for error messages
3. Ensure all prerequisites are installed correctly
4. Verify `.env` file is configured properly

---

