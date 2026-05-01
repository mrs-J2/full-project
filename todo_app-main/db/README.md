# MySQL Database for Todo API

This directory contains the MySQL database configuration for the Todo API backend.

## Files

- `docker-compose.yml` - Docker Compose configuration for MySQL
- `.env` - Environment variables (create from `.env.example`)
- `.env.example` - Example environment variables
- `init.sql` - Optional initialization script
- `README.md` - This file

## Quick Start

### 1. Configure Environment Variables

Copy the example file and update with secure passwords:

```bash
cp .env.example .env
```

Edit `.env` and change the passwords:

```env
MYSQL_ROOT_PASSWORD=your_secure_root_password
MYSQL_DATABASE=tododb
MYSQL_USER=todouser
MYSQL_PASSWORD=your_secure_user_password
MYSQL_PORT=3306
TZ=UTC
```

### 2. Start MySQL

```bash
docker-compose up -d
```

### 3. Verify MySQL is Running

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Check health
docker-compose exec mysql mysqladmin ping -h localhost -u root -p
```

## Connecting from Backend

From your backend server, use these connection details:

- **Host**: IP address or hostname of the MySQL server
- **Port**: 3306 (or your custom port)
- **Database**: tododb
- **User**: todouser
- **Password**: (from your .env file)

Update your backend's `.env` file:

```env
DB_HOST=your.mysql.server.ip
DB_PORT=3306
DB_NAME=tododb
DB_USER=todouser
DB_PASSWORD=your_secure_user_password
```

## Security Considerations

### For Production Deployment

1. **Change Default Passwords**: Use strong, unique passwords
   ```bash
   # Generate secure passwords
   openssl rand -base64 32
   ```

2. **Firewall Rules**: Only allow connections from your backend server
   ```bash
   # Example with UFW
   sudo ufw allow from BACKEND_IP to any port 3306
   ```

3. **Bind to Specific IP**: Edit docker-compose.yml to bind to specific IP instead of 0.0.0.0
   ```yaml
   ports:
     - "192.168.1.100:3306:3306"  # Replace with your server IP
   ```

4. **Use SSL/TLS**: Configure MySQL to use encrypted connections

5. **Regular Backups**: Set up automated database backups

## Database Management

### Access MySQL CLI

```bash
# Using docker exec
docker-compose exec mysql mysql -u root -p

# Or connect to specific database
docker-compose exec mysql mysql -u todouser -p tododb
```

### Create Manual Backup

```bash
# Backup database
docker-compose exec mysql mysqldump -u root -p tododb > backup_$(date +%Y%m%d).sql

# Restore from backup
docker-compose exec -T mysql mysql -u root -p tododb < backup_20260128.sql
```

### View Database Size

```bash
docker-compose exec mysql mysql -u root -p -e "
SELECT 
    table_schema AS 'Database',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema = 'tododb'
GROUP BY table_schema;
"
```

## Docker Commands

```bash
# Start MySQL
docker-compose up -d

# Stop MySQL
docker-compose stop

# Stop and remove container (data persists in volume)
docker-compose down

# Stop and remove everything including data volume
docker-compose down -v

# View logs
docker-compose logs -f

# Restart MySQL
docker-compose restart

# Check resource usage
docker stats todo-mysql
```

## Volume Management

Data is stored in a named Docker volume `mysql_data` which persists even if the container is removed.

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect mysql_mysql_data

# Backup volume
docker run --rm \
  -v mysql_mysql_data:/data \
  -v $(pwd):/backup \
  ubuntu tar czf /backup/mysql_backup.tar.gz /data

# Restore volume
docker run --rm \
  -v mysql_mysql_data:/data \
  -v $(pwd):/backup \
  ubuntu tar xzf /backup/mysql_backup.tar.gz -C /
```

## Monitoring

### Check MySQL Status

```bash
# Check if MySQL is accepting connections
docker-compose exec mysql mysqladmin -u root -p status

# Show process list
docker-compose exec mysql mysql -u root -p -e "SHOW PROCESSLIST;"

# Show databases
docker-compose exec mysql mysql -u root -p -e "SHOW DATABASES;"
```

### Performance Monitoring

```bash
# Check slow queries
docker-compose exec mysql mysql -u root -p -e "SHOW VARIABLES LIKE 'slow_query%';"

# Check connection count
docker-compose exec mysql mysql -u root -p -e "SHOW STATUS WHERE variable_name = 'Threads_connected';"
```

## Troubleshooting

### Cannot Connect to MySQL

1. Check if container is running:
   ```bash
   docker-compose ps
   ```

2. Check logs for errors:
   ```bash
   docker-compose logs mysql
   ```

3. Verify port is accessible:
   ```bash
   netstat -tlnp | grep 3306
   ```

4. Test connection from backend server:
   ```bash
   mysql -h MYSQL_HOST -u todouser -p tododb
   ```

### Container Keeps Restarting

1. Check logs:
   ```bash
   docker-compose logs mysql
   ```

2. Verify environment variables in `.env`

3. Check disk space:
   ```bash
   df -h
   ```

### Permission Issues

If you get permission errors, ensure the MySQL user has proper privileges:

```bash
docker-compose exec mysql mysql -u root -p -e "
GRANT ALL PRIVILEGES ON tododb.* TO 'todouser'@'%';
FLUSH PRIVILEGES;
"
```

### Reset Everything

To completely reset and start fresh:

```bash
# Stop and remove everything
docker-compose down -v

# Start again
docker-compose up -d
```

## Network Configuration

### Expose to Other Servers

To allow connections from other servers, ensure:

1. Port is mapped in docker-compose.yml (already configured)
2. Firewall allows incoming connections on port 3306
3. MySQL user has '%' host (already configured)

### Use Custom Network

If your backend is on the same Docker host, you can use a custom network:

```yaml
networks:
  todo-network:
    external: true
```

Then create the network:
```bash
docker network create todo-network
```

## Production Best Practices

1. **Use specific MySQL version**: Change `mysql:8.0` to `mysql:8.0.35` for consistency
2. **Configure memory limits**: Add resource constraints in docker-compose.yml
3. **Set up monitoring**: Use tools like Prometheus + Grafana
4. **Enable binary logs**: For point-in-time recovery
5. **Regular backups**: Automate with cron jobs
6. **Use secrets**: Instead of environment variables for passwords
7. **Limit connections**: Set max_connections in MySQL config
8. **Monitor disk usage**: Set up alerts for low disk space

## Support

For MySQL-specific issues, consult:
- [MySQL Docker Official Documentation](https://hub.docker.com/_/mysql)
- [MySQL 8.0 Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/)

For Todo API integration issues, refer to the backend README.
