#!/bin/bash

echo "Waiting for the database to be ready..."
node src/wait-for-db.js || exit 1
npx npm run migrate
echo "======== Starting the application ========"
npx npm start
