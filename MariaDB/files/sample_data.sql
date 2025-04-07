-- Create a flexible users table with JSON for dynamic attributes
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    profile_data JSON,  -- Store dynamic user attributes
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT email_format CHECK (email REGEXP '^[^@]+@[^@]+\.[^@]+$')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample records with dynamic data
INSERT INTO users (username, email, profile_data) VALUES
('john_doe', 'john@example.com', '{"first_name": "John", "last_name": "Doe", "age": 30, "preferences": {"theme": "dark", "notifications": true}}'),
('jane_smith', 'jane@example.com', '{"first_name": "Jane", "last_name": "Smith", "age": 28, "preferences": {"theme": "light", "notifications": false}}'),
('alex_wong', 'alex@example.com', '{"first_name": "Alex", "last_name": "Wong", "age": 35, "preferences": {"theme": "system", "notifications": true}}');

-- Create indexes for performance
CREATE INDEX idx_username ON users(username);
CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_status ON users(status);
CREATE INDEX idx_profile_data ON users((CAST(profile_data->>'$.age' AS UNSIGNED)));

-- Add a procedure to dynamically add columns if needed
DELIMITER //
CREATE PROCEDURE add_user_column(IN column_name VARCHAR(50), IN column_type VARCHAR(50))
BEGIN
    SET @sql = CONCAT('ALTER TABLE users ADD COLUMN ', column_name, ' ', column_type, ';');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //
DELIMITER ;
