# Todo API - FastAPI Backend

A RESTful API for managing todos, built with FastAPI and MySQL.

## Features

- ✅ User authentication with JWT tokens
- ✅ CRUD operations for todos
- ✅ MySQL database integration
- ✅ Docker containerization
- ✅ Environment-based configuration
- ✅ Comprehensive error handling

## Tech Stack

- **FastAPI**: Modern Python web framework
- **SQLAlchemy**: SQL toolkit and ORM
- **MySQL**: Relational database (external)
- **JWT**: Token-based authentication
- **Docker**: Containerization
- **Uvicorn**: ASGI server

## Project Structure

```
.
├── main.py              # FastAPI application and endpoints
├── models.py            # SQLAlchemy database models
├── schemas.py           # Pydantic schemas for validation
├── database.py          # Database configuration
├── auth.py              # Authentication utilities
├── requirements.txt     # Python dependencies
├── Dockerfile           # Docker image configuration
├── docker-compose.yml   # Docker Compose setup
├── .env.example         # Example environment variables
└── README.md            # This file
```

## Prerequisites

- Docker and Docker Compose
- MySQL database server (running separately)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd todo-api
```

### 2. Configure Environment Variables

Copy the example environment file and update with your values:

```bash
cp .env.example .env
```

Edit `.env` with your database credentials:

```env
# Database Configuration
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_HOST=your_mysql_host  # e.g., mysql.example.com or IP address
DB_PORT=3306
DB_NAME=tododb

# JWT Configuration
SECRET_KEY=your-super-secret-key-here  # Generate with: openssl rand -hex 32
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=10080  # 7 days

# Application Configuration
APP_HOST=0.0.0.0
APP_PORT=8000
```

### 3. Prepare MySQL Database

On your MySQL server, create the database:

```sql
CREATE DATABASE tododb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'your_db_user'@'%' IDENTIFIED BY 'your_db_password';
GRANT ALL PRIVILEGES ON tododb.* TO 'your_db_user'@'%';
FLUSH PRIVILEGES;
```

Ensure your MySQL server allows connections from the backend server's IP address.

### 4. Build and Run with Docker

```bash
# Build the Docker image
docker build -t todo-api .

# Run the container
docker run -d \
  --name todo-api \
  -p 8000:8000 \
  --env-file .env \
  todo-api
```

Or using Docker Compose:

```bash
docker-compose up -d
```

### 5. Verify the API is Running

```bash
curl http://localhost:8000/
```

You should see: `{"message":"Todo API is running"}`

## API Documentation

Once the server is running, access the interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

## API Endpoints

### Authentication

- `POST /auth/register` - Register a new user
- `POST /auth/login` - Login and receive JWT token

### Todos

- `GET /todos` - Get all todos (with optional filters)
- `GET /todos/{id}` - Get a specific todo
- `POST /todos` - Create a new todo
- `PUT /todos/{id}` - Update a todo
- `DELETE /todos/{id}` - Delete a todo

All todo endpoints require authentication via Bearer token.

## Example Usage

### 1. Register a User

```bash
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "testpass123"
  }'
```

Response:
```json
{
  "id": "uuid-here",
  "username": "testuser",
  "token": "jwt-token-here"
}
```

### 2. Login

```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "testpass123"
  }'
```

### 3. Create a Todo

```bash
curl -X POST http://localhost:8000/todos \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "title": "Buy groceries",
    "description": "Milk, eggs, bread"
  }'
```

### 4. Get All Todos

```bash
curl -X GET http://localhost:8000/todos \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### 5. Update a Todo

```bash
curl -X PUT http://localhost:8000/todos/TODO_ID \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "completed": true
  }'
```

### 6. Delete a Todo

```bash
curl -X DELETE http://localhost:8000/todos/TODO_ID \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Docker Commands

```bash
# Build image
docker build -t todo-api .

# Run container
docker run -d -p 8000:8000 --env-file .env --name todo-api todo-api

# View logs
docker logs todo-api

# Stop container
docker stop todo-api

# Remove container
docker rm todo-api

# Using Docker Compose
docker-compose up -d        # Start
docker-compose logs -f      # View logs
docker-compose down         # Stop and remove
```

## Database Schema

### Users Table
- `id` (VARCHAR 36, PRIMARY KEY)
- `username` (VARCHAR 255, UNIQUE)
- `hashed_password` (VARCHAR 255)
- `created_at` (DATETIME)

### Todos Table
- `id` (VARCHAR 36, PRIMARY KEY)
- `title` (VARCHAR 255)
- `description` (TEXT)
- `completed` (BOOLEAN)
- `created_at` (DATETIME)
- `updated_at` (DATETIME)
- `user_id` (VARCHAR 36, FOREIGN KEY)

## Security Considerations

1. **Change the SECRET_KEY**: Generate a secure random key:
   ```bash
   openssl rand -hex 32
   ```

2. **Use HTTPS**: In production, always use HTTPS

3. **Secure Database**: Use strong passwords and limit network access

4. **Environment Variables**: Never commit `.env` file to version control

5. **CORS**: Configure CORS settings for production use

## Production Deployment

For production deployment:

1. Use a reverse proxy (Nginx/Traefik)
2. Enable HTTPS with SSL certificates
3. Use a production-grade ASGI server configuration
4. Set up monitoring and logging
5. Configure database connection pooling
6. Implement rate limiting
7. Set up backup strategies

## Troubleshooting

### Cannot connect to MySQL

- Verify MySQL server is running
- Check firewall rules allow connection from backend
- Verify database credentials in `.env`
- Ensure database exists

### Database tables not created

The application automatically creates tables on startup. If they're not created:
- Check database permissions
- Verify database connection
- Check application logs: `docker logs todo-api`

### Token errors

- Verify SECRET_KEY is set correctly
- Check token hasn't expired
- Ensure Authorization header format: `Bearer <token>`

## License

MIT License

## Support

For issues and questions, please open an issue on the repository.
