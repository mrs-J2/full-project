-- Initial database setup script
-- This runs automatically when the container is first created

-- Set character set and collation
ALTER DATABASE tododb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges (already done by environment variables, but adding for completeness)
GRANT ALL PRIVILEGES ON tododb.* TO 'todouser'@'%';
FLUSH PRIVILEGES;

-- Optional: Create indexes or initial data here
-- Tables will be created automatically by SQLAlchemy
