-- Create a sample database table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
-- Insert sample records
INSERT INTO users (username, email) VALUES
('sam_k', 'sam@example.com'),
('harry_potter', 'harry@example.com'),
('penny_jakes', 'penny@example.com');
-- Add an index for better query performance
CREATE INDEX idx_username ON users(username);