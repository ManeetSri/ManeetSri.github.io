// Everything the engines derive for a fixed DSA learner must match what they derived before the console
// became multi-course. To re-record deliberately: GOLDEN_UPDATE=1 node --test src/dsa/engine/golden.test.js
process.env.TZ = 'Asia/Kolkata';

import { test } from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, readFileSync, writeFileSync } from 'node:fs';
import { buildFixture, summarize } from './golden.fixture.js';

const expectedFile = new URL('./golden.expected.json', import.meta.url);

test('the DSA engines derive exactly what they did before the multi-course refactor', () => {
    const actual = JSON.parse(JSON.stringify(summarize(buildFixture())));
    if (process.env.GOLDEN_UPDATE || !existsSync(expectedFile)) {
        writeFileSync(expectedFile, `${JSON.stringify(actual, null, 2)}\n`);
        return;
    }
    assert.deepEqual(actual, JSON.parse(readFileSync(expectedFile, 'utf8')));
});
