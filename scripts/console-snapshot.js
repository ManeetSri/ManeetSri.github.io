// Prints what the engines derive from a real progress backup (Settings → Download a backup), so a refactor
// can be checked against real data, not just the golden fixture. Keep the output outside git.
//   node scripts/console-snapshot.js <backup.json> [--now <ms>] > before.json
// Run it before and after a change with the same --now, then diff the two files.
import { readFileSync } from 'node:fs';
import { summarize } from '../src/dsa/engine/golden.fixture.js';

const [file, ...rest] = process.argv.slice(2);
if (!file) {
    console.error('Usage: node scripts/console-snapshot.js <backup.json> [--now <ms>]');
    process.exit(1);
}
const nowFlag = rest.indexOf('--now');
const now = nowFlag >= 0 ? Number(rest[nowFlag + 1]) : Date.now();
const backup = JSON.parse(readFileSync(file, 'utf8'));
const state = Object.fromEntries(['lessons', 'problems', 'cards', 'checkpoints', 'mocks', 'activity'].map((name) => [name, backup[name] ?? {}]));
console.log(JSON.stringify({ now, ...summarize(state, now) }, null, 2));
