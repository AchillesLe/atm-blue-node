const db = require('./config/database');

const MAX = 3;
const WAIT = 3000;

(async () => {
  for (let i = 1; i <= MAX; i++) {
    try {
      await db.raw('select 1');
      await db.destroy();
      process.exit(0);
    } catch {
      if (i === MAX) process.exit(1);
      await new Promise((r) => setTimeout(r, WAIT));
    }
  }
})();
