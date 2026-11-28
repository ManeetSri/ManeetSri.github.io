import { test } from 'node:test';
import assert from 'node:assert/strict';
import { compileEstimator, estimatorSchema, logSteps, positionOf, valueAt } from './estimator.js';
import { formatValue, withUnit } from './format.js';

const users = { id: 'dau', label: 'Daily users', min: 1000, max: 1e9, value: 1e6, scale: 'log' };
const perUser = { id: 'perUser', label: 'Requests per user', min: 1, max: 100, step: 1, value: 10 };
const good = {
    inputs: [users, perUser],
    outputs: [
        { id: 'qps', label: 'Average QPS', formula: 'dau * perUser / 86400', format: 'si', unit: '/s' },
        { id: 'peak', label: 'Peak QPS', formula: 'qps * 3', format: 'si' },
        { id: 'servers', label: 'Servers', formula: 'ceil(peak / 500)' },
    ],
};

test('formats: si, bytes, duration and number', () => {
    assert.equal(formatValue(1234, 'si'), '1.23k');
    assert.equal(formatValue(1200, 'si'), '1.2k');
    assert.equal(formatValue(3.4e6, 'si'), '3.4M');
    assert.equal(formatValue(999950, 'si'), '1M');
    assert.equal(formatValue(123456, 'si'), '123k');
    assert.equal(formatValue(42, 'si'), '42');
    assert.equal(formatValue(0.256, 'si'), '0.256');
    assert.equal(formatValue(-2500, 'si'), '−2.5k');
    assert.equal(formatValue(2.5e9, 'si'), '2.5B');
    assert.equal(formatValue(7e12, 'si'), '7T');
    assert.equal(formatValue(999.6e12, 'si'), '1 × 10¹⁵');
    assert.equal(formatValue(3.2e18, 'si'), '3.2 × 10¹⁸');
    assert.equal(formatValue(512, 'bytes'), '512 B');
    assert.equal(formatValue(1500, 'bytes'), '1.5 KB');
    assert.equal(formatValue(2e9, 'bytes'), '2 GB');
    assert.equal(formatValue(7.3e12, 'bytes'), '7.3 TB');
    assert.equal(formatValue(0.0005, 'duration'), '500 µs');
    assert.equal(formatValue(0.25, 'duration'), '250 ms');
    assert.equal(formatValue(42, 'duration'), '42 s');
    assert.equal(formatValue(59.99, 'duration'), '1 min');
    assert.equal(formatValue(5400, 'duration'), '1.5 h');
    assert.equal(formatValue(86400 * 3, 'duration'), '3 days');
    assert.equal(formatValue(86400 * 730, 'duration'), '2 years');
    assert.equal(formatValue(1234567.891, 'number'), '1,234,567.89');
    assert.equal(formatValue(0.000123, 'number'), '0.000123');
    assert.equal(formatValue(Infinity, 'si'), '∞');
    assert.equal(formatValue(NaN), '—');
    assert.equal(withUnit('12 GB', '/day'), '12 GB/day');
    assert.equal(withUnit('3', 'servers'), '3 servers');
    assert.equal(withUnit('3'), '3');
});

test('outputs chain through earlier outputs', () => {
    const work = compileEstimator(good.outputs);
    const [qps, peak, servers] = work({ dau: 1e6, perUser: 10 });
    assert.ok(Math.abs(qps.value - 1e7 / 86400) < 1e-9);
    assert.ok(Math.abs(peak.value - (3e7 / 86400)) < 1e-9);
    assert.equal(servers.value, 1);
    assert.ok(Number.isNaN(compileEstimator([{ id: 'x', formula: 'missing + 1' }])({})[0].value));
});

test('log sliders map positions to round values and back', () => {
    const steps = logSteps(users);
    assert.equal(steps, 144);
    assert.equal(valueAt(users, 0), 1000);
    assert.equal(valueAt(users, steps), 1e9);
    assert.equal(positionOf(users, 1e6), steps / 2);
    assert.equal(valueAt(users, steps / 2), 1e6);
    // Every step lands on a different, rounder value, so arrow keys always move it
    const values = Array.from({ length: steps + 1 }, (_, position) => valueAt(users, position));
    values.slice(1).forEach((value, index) => assert.ok(value > values[index], `step ${index + 1}: ${value} after ${values[index]}`));
    values.slice(1, -1).forEach((value) => assert.equal(Number(value.toPrecision(2)), value));
    assert.equal(logSteps({ min: 1, max: 2 }), 24);
    // Linear sliders snap to the step and stay in range
    assert.equal(valueAt(perUser, 10.4), 10);
    assert.equal(valueAt({ ...perUser, step: 5, min: 0 }, 12), 10);
    assert.equal(valueAt(perUser, 1000), 100);
    assert.equal(positionOf(perUser, 42), 42);
});

test('estimator schema accepts good settings', () => {
    assert.equal(estimatorSchema(good), true);
    assert.equal(estimatorSchema({ title: 'Storage', inputs: [{ id: 'gb', label: 'GB', min: 0, max: 10, value: 5 }], outputs: [{ id: 'bytes', label: 'Bytes', formula: 'gb * 1e9', format: 'bytes' }, { id: 'constant', label: 'A constant', formula: 86400, format: 'duration' }] }), true);
});

test('estimator schema rejects bad formulas, forward references and bad sliders', () => {
    const withOutputs = (outputs) => ({ inputs: [users, perUser], outputs });
    const withInput = (change) => ({ inputs: [{ ...perUser, ...change }], outputs: [{ id: 'out', label: 'Out', formula: '1' }] });
    const cases = [
        [{ outputs: good.outputs }, /`inputs` must be a list/],
        [{ inputs: [users] }, /`outputs` must be a list/],
        [withOutputs([{ id: 'a', label: 'A', formula: 'dau * peak' }, { id: 'peak', label: 'P', formula: '1' }]), /uses `peak`, which is worked out by a later output \(outputs\[1\]\); move a below it/],
        [withOutputs([{ id: 'a', label: 'A', formula: 'a + 1' }]), /uses its own id `a`/],
        [withOutputs([{ id: 'a', label: 'A', formula: 'dau * users' }]), /unknown name `users` in the formula \(inputs: dau, perUser\)/],
        [withOutputs([{ id: 'a', label: 'A', formula: '1' }, { id: 'b', label: 'B', formula: 'zzz' }]), /\(inputs: dau, perUser; earlier outputs: a\)/],
        [withOutputs([{ id: 'a', label: 'A', formula: 'pow(dau, 2)' }]), /outputs\[0\] \(a\): the formula "pow\(dau, 2\)" doesn't parse: unknown function "pow"/],
        [withOutputs([{ id: 'a', label: 'A', formula: 'dau * (perUser' }]), /doesn't parse: expected "\)"/],
        [withOutputs([{ id: 'a', label: 'A', formula: 'dau / (perUser - 10)' }]), /gives Infinity at the starting values/],
        [withOutputs([{ id: 'a', label: 'A' }]), /needs a `formula`/],
        [withOutputs([{ id: 'a', label: 'A', formula: '1', format: 'percent' }]), /unknown `format` "percent"/],
        [withOutputs([{ id: 'dau', label: 'A', formula: '1' }]), /the id `dau` is already used/],
        [withOutputs([{ id: 'max', label: 'A', formula: '1' }]), /`max` is a function name/],
        [withOutputs([{ id: '2fast', label: 'A', formula: '1' }]), /needs an `id` made of letters/],
        [withOutputs([{ id: 'a', formula: '1' }]), /needs a `label`/],
        [withOutputs([{ id: 'a', label: 'A', formula: '1', units: 'x' }]), /unknown field `units`/],
        [withInput({ min: 10, max: 5 }), /inputs\[0\] \(perUser\): `min` \(10\) must be less than `max` \(5\)/],
        [withInput({ value: 500 }), /`value` must be at most 100/],
        [withInput({ step: 0 }), /`step` must be more than 0/],
        [withInput({ step: 3, value: 11 }), /isn't a whole number of steps/],
        [withInput({ scale: 'exp' }), /unknown `scale` "exp"/],
        [withInput({ scale: 'log', min: 0 }), /a log scale needs `min` above 0/],
        [withInput({ label: '' }), /needs a `label`/],
        [{ inputs: [perUser, perUser], outputs: [{ id: 'a', label: 'A', formula: '1' }] }, /the id `perUser` is already used/],
        [{ ...good, extra: 1 }, /unknown field `extra`/],
    ];
    cases.forEach(([props, pattern]) => {
        const verdict = estimatorSchema(props);
        assert.equal(typeof verdict, 'string', `expected a problem for ${JSON.stringify(props)}`);
        assert.match(verdict, pattern);
    });
});
