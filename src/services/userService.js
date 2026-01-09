const mysql = require('mysql2/promise');

const pool = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  port: process.env.DB_PORT,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

async function getUserCount() {
  try {
    const [rows] = await pool.query('SELECT COUNT(*) as count FROM users');
    return rows[0].count;
  } catch (error) {
    console.log({error});
    console.error('Database error in getUserCount:', error);
    return null;
  }
}

async function createUser(username, email, fullName) {
  try {
    const [result] = await pool.query(
      'INSERT INTO users (username, email, full_name) VALUES (?, ?, ?)',
      [username, email, fullName]
    );
    return {
      id: result.insertId,
      username,
      email,
      fullName
    };
  } catch (error) {
    console.error('Database error in createUser:', error);
    throw error;
  }
}

module.exports = {
  getUserCount,
  createUser
};
