CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE,
  full_name VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO users (username, email, full_name) VALUES
('john_doe', 'john@example.com', 'John Doe'),
('jane_smith', 'jane@example.com', 'Jane Smith'),
('bob_wilson', 'bob@example.com', 'Bob Wilson'),
('alice_jones', 'alice@example.com', 'Alice Jones'),
('charlie_brown', 'charlie@example.com', 'Charlie Brown');
