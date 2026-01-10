const db = require('../config/database');

async function getUserCount() {
  try {
    const result = await db('users').count('* as count').first();
    return result.count;
  } catch (error) {
    console.log({ error });
    console.error('Database error in getUserCount:', error);
    return null;
  }
}

async function createUser(username, email, fullName) {
  try {
    const [id] = await db('users').insert({
      username,
      email,
      full_name: fullName,
    });
    return {
      id,
      username,
      email,
      fullName,
    };
  } catch (error) {
    console.error('Database error in createUser:', error);
    throw error;
  }
}

module.exports = {
  getUserCount,
  createUser,
};
