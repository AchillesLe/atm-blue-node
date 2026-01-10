#!/bin/bash
set -e

echo "Waiting for the database to be ready..."
if node src/wait-for-db.js; then
  echo "Database ready. Running migrations..."
  npm run migrate
else
  echo "Database not ready. Skipping migrations."
fi

echo "======== Starting the application ========"
exec npm start
