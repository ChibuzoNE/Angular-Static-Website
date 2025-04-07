-- Add this before creating the index
SET @index_exists := (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'users'
    AND index_name = 'idx_username'
);

-- Conditionally create index
SET @create_index := IF(@index_exists = 0, 'CREATE INDEX idx_username ON users(username)', 'SELECT "Index already exists"');
PREPARE stmt FROM @create_index;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;