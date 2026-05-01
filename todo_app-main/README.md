# Todo Application

A full-stack todo application with Docker deployment.

## Deployment

### Step 1: Start the Database
Launch the database container using the docker-compose file:
```bash
cd db
docker-compose up -d
```
Ensure the database configuration in `db/.env` is properly set up before starting.

### Step 2: Start the Backend
Launch the backend service:
```bash
cd backend
docker-compose up -d
```
**Important**: Update the `db_host` variable in your backend configuration to point to your database server's public IP address or EC2 instance hostname.

### Step 3: Start the Frontend
Launch the frontend application:
```bash
cd frontend
docker-compose up -d
```
**Important**: Update the API URL configuration to include your backend service's public IP address so the frontend can communicate with the backend API.

### Network Configuration
- Ensure all containers can communicate across your network
- Open necessary ports in your firewall/security groups
- Verify connectivity between services before testing the application

## API Documentation

For detailed API endpoints and usage, see [todo_api_docs.md](todo_api_docs.md)