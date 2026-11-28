import { test } from 'node:test';
import assert from 'node:assert/strict';
import { ExprError, calculate, namesIn, parse } from './expr.js';

test('numbers, including decimals and exponents', () => {
    assert.equal(calculate('42'), 42);
    assert.equal(calculate('0.5'), 0.5);
    assert.equal(calculate('.25'), 0.25);
    assert.equal(calculate('1e6'), 1e6);
    assert.equal(calculate('2.5E-3'), 0.0025);
    assert.equal(calculate('3e+2'), 300);
    assert.equal(calculate(7), 7);
});

test('precedence and associativity', () => {
    assert.equal(calculate('1 + 2 * 3'), 7);
    assert.equal(calculate('(1 + 2) * 3'), 9);
    assert.equal(calculate('10 - 4 - 3'), 3);
    assert.equal(calculate('100 / 10 / 5'), 2);
    assert.equal(calculate('2 ^ 3 ^ 2'), 512);
    assert.equal(calculate('2 * 3 ^ 2'), 18);
    assert.equal(calculate('-2 ^ 2'), -4);
    assert.equal(calculate('(-2) ^ 2'), 4);
    assert.equal(calculate('2 ^ -1'), 0.5);
    assert.equal(calculate('--3'), 3);
    assert.equal(calculate('+3 - -2'), 5);
    assert.equal(calculate('17 % 5 * 2'), 4);
    assert.equal(calculate('1 + 17 % 5'), 3);
});

test('names and functions', () => {
    const scope = { users: 1e6, perUser: 10, seconds: 86400 };
    assert.equal(calculate('users * perUser / seconds', scope), 1e7 / 86400);
    assert.equal(calculate('max(1, 5, 3)'), 5);
    assert.equal(calculate('min(4)'), 4);
    assert.equal(calculate('ceil(1.2) + floor(1.8) + round(2.5)'), 2 + 1 + 3);
    assert.equal(calculate('log10(1000) + log2(8) + sqrt(16) + abs(-2)'), 3 + 3 + 4 + 2);
    assert.equal(calculate('ceil(users / max(perUser, 1) / 1e3)', scope), 100);
    assert.equal(calculate('1 / 0'), Infinity);
    assert.deepEqual(namesIn(parse('a * b + max(a, c) - 2')), ['a', 'b', 'c']);
});

test('the scope only counts its own properties', () => {
    assert.throws(() => calculate('constructor', {}), /unknown name "constructor"/);
    assert.throws(() => calculate('toString + 1', {}), ExprError);
});

test('readable errors', () => {
    const cases = [
        ['', /empty/],
        ['   ', /empty/],
        ['1 +', /ends too early/],
        ['(1 + 2', /expected "\)" to close the "\(" at character 1/],
        ['1 + 2)', /unexpected "\)" at character 6/],
        ['2x', /write 2 \* x to multiply/],
        ['2 (3)', /write 2 \* \(…\) to multiply/],
        ['pow(2, 3)', /unknown function "pow"/],
        ['max()', /at least 1, not 0/],
        ['sqrt(1, 2)', /exactly 1 argument, not 2/],
        ['max(1, 2', /expected "," or "\)" in max/],
        ['1 $ 2', /unexpected character "\$" at character 3/],
        ['eval("1")', /unexpected character/],
        ['a.b', /unexpected/],
        ['* 3', /unexpected "\*" at character 1/],
    ];
    cases.forEach(([source, pattern]) => {
        assert.throws(() => parse(source), (error) => error instanceof ExprError && pattern.test(error.message), `"${source}" should fail with ${pattern}`);
    });
    assert.throws(() => parse({}), /must be text/);
    assert.throws(() => parse('1+'.repeat(300) + '1'), /longer than 500/);
});
