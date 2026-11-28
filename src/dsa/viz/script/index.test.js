import { test } from 'node:test';
import assert from 'node:assert/strict';
import { SCRIPT_NAMES, SCRIPT_SCHEMAS } from './index.js';
import { SCRIPT_VISUALS } from './views.js';
import { VISUAL_NAMES } from '../names.js';
import { VISUAL_SCHEMAS } from '../schemas.js';

test('every scripted view has a schema, and the build knows both', () => {
    assert.deepEqual(Object.keys(SCRIPT_VISUALS).sort(), ['flow', 'sequence', 'states', 'timeline']);
    assert.deepEqual(Object.keys(SCRIPT_SCHEMAS).sort(), Object.keys(SCRIPT_VISUALS).sort());
    assert.deepEqual([...SCRIPT_NAMES].sort(), Object.keys(SCRIPT_VISUALS).sort());
    Object.keys(SCRIPT_VISUALS).forEach((name) => {
        assert.ok(VISUAL_NAMES.includes(name), `${name} is a visual name`);
        assert.equal(VISUAL_SCHEMAS[name], SCRIPT_SCHEMAS[name]);
        assert.equal(typeof SCRIPT_VISUALS[name], 'function');
    });
});

test('schemas cope with empty or odd props without throwing', () => {
    Object.values(SCRIPT_SCHEMAS).forEach((check) => {
        [undefined, null, {}, [], 'text', { nodes: 'x', participants: 'x', states: 'x', lanes: 'x' }].forEach((props) => {
            assert.equal(typeof check(props), 'string');
        });
    });
});
