/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = async function (knex) {
  await knex.schema.createTable('users', function (table) {
    table.increments('id').primary();
    table.string('username', 50).notNullable().unique();
    table.string('email', 100).notNullable().unique();
    table.string('full_name', 100);
    table.timestamp('created_at').defaultTo(knex.fn.now());
  });

  // Insert initial data
  await knex('users').insert([
    { username: 'john_doe', email: 'john@example.com', full_name: 'John Doe' },
    { username: 'jane_smith', email: 'jane@example.com', full_name: 'Jane Smith' },
    { username: 'bob_wilson', email: 'bob@example.com', full_name: 'Bob Wilson' },
    { username: 'alice_jones', email: 'alice@example.com', full_name: 'Alice Jones' },
    { username: 'charlie_brown', email: 'charlie@example.com', full_name: 'Charlie Brown' },
  ]);
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = async function (knex) {
  await knex.schema.dropTableIfExists('users');
};
