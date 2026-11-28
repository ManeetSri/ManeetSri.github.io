// Small programs run step by step, the way you'd fill in a trace table by hand: each frame has the
// current value of every variable, the table of rows so far (one per loop pass), the Swift line and a message.

const PROGRAMS = {
    sum: {
        title: 'Adding up an array',
        code: `var total = 0
for number in numbers {
    total += number
}
print(total)`,
        columns: ['number', 'total'],
        defaults: { numbers: [4, 7, 1, 9] },
        * run({ numbers }) {
            let total = 0;
            yield { line: 1, vars: { total }, message: 'Start the running total at 0.' };
            for (const number of numbers) {
                yield { line: 2, vars: { number, total }, message: `Next number: ${number}.` };
                total += number;
                yield { line: 3, vars: { number, total }, row: { number, total }, message: `total += ${number}, so total is now ${total}.` };
            }
            yield { line: 5, vars: { total }, message: `The loop is finished. Print ${total}.` };
        },
    },
    largest: {
        title: 'Finding the largest number',
        code: `var best = numbers[0]
for number in numbers {
    if number > best {
        best = number
    }
}
print(best)`,
        columns: ['number', 'number > best?', 'best'],
        defaults: { numbers: [4, 11, 7, 15, 2] },
        * run({ numbers }) {
            let best = numbers[0];
            yield { line: 1, vars: { best }, message: `Start with the first element: best = ${best}.` };
            for (const number of numbers) {
                const bigger = number > best;
                yield { line: 3, vars: { number, best }, message: `Is ${number} > ${best}? ${bigger ? 'Yes' : 'No'}.` };
                if (bigger) {
                    best = number;
                    yield { line: 4, vars: { number, best }, message: `So best becomes ${best}.` };
                }
                yield { line: 2, vars: { number, best }, row: { number, 'number > best?': bigger ? 'yes' : 'no', best }, message: `Row done: best is ${best}.` };
            }
            yield { line: 7, vars: { best }, message: `Print ${best}.` };
        },
    },
    reverseDigits: {
        title: 'Reversing the digits of a number',
        code: `var n = number
var reversed = 0
while n > 0 {
    let digit = n % 10
    reversed = reversed * 10 + digit
    n /= 10
}
print(reversed)`,
        columns: ['digit', 'reversed', 'n'],
        defaults: { number: 1234 },
        * run({ number }) {
            let n = number;
            let reversed = 0;
            yield { line: 2, vars: { n, reversed }, message: `Start with n = ${n} and reversed = 0.` };
            while (n > 0) {
                yield { line: 3, vars: { n, reversed }, message: `${n} > 0, so go round the loop again.` };
                const digit = n % 10;
                yield { line: 4, vars: { n, reversed, digit }, message: `${n} % 10 = ${digit}: the last digit.` };
                reversed = reversed * 10 + digit;
                yield { line: 5, vars: { n, reversed, digit }, message: `Shift reversed left one place and add ${digit}: ${reversed}.` };
                n = Math.floor(n / 10);
                yield { line: 6, vars: { n, reversed, digit }, row: { digit, reversed, n }, message: `n /= 10 drops the last digit: n = ${n}.` };
            }
            yield { line: 8, vars: { n, reversed }, message: `n is 0, so the loop ends. Print ${reversed}.` };
        },
    },
    gcd: {
        title: 'Euclid’s greatest common divisor',
        code: `var a = first
var b = second
while b != 0 {
    let remainder = a % b
    a = b
    b = remainder
}
print(a)`,
        columns: ['a', 'b', 'a % b'],
        defaults: { first: 48, second: 18 },
        * run({ first, second }) {
            let a = first;
            let b = second;
            yield { line: 2, vars: { a, b }, message: `Start with a = ${a} and b = ${b}.` };
            while (b !== 0) {
                const remainder = a % b;
                yield { line: 4, vars: { a, b, remainder }, row: { a, b, 'a % b': remainder }, message: `${a} % ${b} = ${remainder}.` };
                a = b;
                b = remainder;
                yield { line: 6, vars: { a, b }, message: `Shift along: a = ${a}, b = ${b}.` };
            }
            yield { line: 8, vars: { a, b }, message: `b is 0, so the answer is a = ${a}.` };
        },
    },
    fastPower: {
        title: 'Fast exponentiation by squaring',
        code: `func power(_ base: Int, _ exponent: Int) -> Int {
    var result = 1
    var square = base
    var e = exponent
    while e > 0 {
        if e % 2 == 1 {
            result *= square
        }
        e /= 2
        if e > 0 {
            square *= square
        }
    }
    return result
}`,
        columns: ['e', 'bit', 'result', 'square'],
        defaults: { base: 3, exponent: 13 },
        * run({ base, exponent }) {
            let result = 1;
            let square = base;
            let e = exponent;
            yield { line: 4, vars: { result, square, e }, message: `${exponent} is ${exponent.toString(2)} in binary: one pass per bit, about log₂(${exponent}) passes instead of ${exponent} multiplications.` };
            while (e > 0) {
                const bit = e % 2;
                yield { line: 6, vars: { result, square, e }, message: `The lowest bit of ${e} is ${bit}${bit ? `, so ${square} is part of the answer.` : ', so skip it.'}` };
                if (bit === 1) {
                    result *= square;
                    yield { line: 7, vars: { result, square, e }, message: `result *= ${square} → ${result}.` };
                }
                const row = { e, bit, result, square };
                e = Math.floor(e / 2);
                if (e > 0) square *= square;
                yield { line: e > 0 ? 11 : 9, vars: { result, square, e }, row, message: e > 0 ? `Drop the bit (e = ${e}) and square: ${square}.` : 'e is 0: no bits left, and no needless final square.' };
            }
            yield { line: 14, vars: { result }, message: `${base}^${exponent} = ${result}.` };
        },
    },
};

export const TRACE_PROGRAMS = Object.keys(PROGRAMS);

export const traceProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown trace program "${name}"`);
    return program;
};

export const traceFrames = (name, input = {}) => {
    const program = traceProgram(name);
    const rows = [];
    return [...program.run({ ...program.defaults, ...input })].map((step) => {
        if (step.row) rows.push(step.row);
        return { ...step, rows: [...rows], newRow: Boolean(step.row) };
    });
};
