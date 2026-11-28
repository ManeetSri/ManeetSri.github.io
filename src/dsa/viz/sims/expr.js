// A small, safe formula language for the estimator. The site's CSP forbids eval and new Function, so formulas
// are tokenised, parsed into a tree and walked here.
//   numbers: 12, 0.5, .5, 1e6, 2.5E-3
//   operators, loosest first: + -, then * / % (remainder), then unary minus, then ^ (power, right-associative,
//     so 2^3^2 is 2^9 and -2^2 is -4)
//   names: [A-Za-z_][A-Za-z0-9_]*, looked up in the scope you evaluate with
//   functions: min, max (one or more arguments), ceil, floor, round, log10, log2, sqrt, abs (one each)
// parse(text) returns a tree or throws an ExprError with a readable message and the character it points at.

export class ExprError extends Error {
    constructor(message, at = null) {
        super(message);
        this.name = 'ExprError';
        this.at = at;
    }
}

export const FUNCTIONS = {
    min: { arity: [1, Infinity], apply: (args) => Math.min(...args) },
    max: { arity: [1, Infinity], apply: (args) => Math.max(...args) },
    ceil: { arity: [1, 1], apply: ([value]) => Math.ceil(value) },
    floor: { arity: [1, 1], apply: ([value]) => Math.floor(value) },
    round: { arity: [1, 1], apply: ([value]) => Math.round(value) },
    log10: { arity: [1, 1], apply: ([value]) => Math.log10(value) },
    log2: { arity: [1, 1], apply: ([value]) => Math.log2(value) },
    sqrt: { arity: [1, 1], apply: ([value]) => Math.sqrt(value) },
    abs: { arity: [1, 1], apply: ([value]) => Math.abs(value) },
};
export const FUNCTION_NAMES = Object.keys(FUNCTIONS);
export const NAME_PATTERN = /^[A-Za-z_][A-Za-z0-9_]*$/;
const MAX_LENGTH = 500;
const OPERATORS = '+-*/%^(),';

const tokenize = (text) => {
    const tokens = [];
    let at = 0;
    while (at < text.length) {
        const rest = text.slice(at);
        const space = /^\s+/.exec(rest);
        if (space) { at += space[0].length; continue; }
        const number = /^(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?/.exec(rest);
        if (number) {
            tokens.push({ type: 'number', value: Number(number[0]), text: number[0], at });
            at += number[0].length;
            continue;
        }
        const name = /^[A-Za-z_][A-Za-z0-9_]*/.exec(rest);
        if (name) {
            tokens.push({ type: 'name', text: name[0], at });
            at += name[0].length;
            continue;
        }
        if (OPERATORS.includes(rest[0])) {
            tokens.push({ type: rest[0], text: rest[0], at });
            at += 1;
            continue;
        }
        throw new ExprError(`unexpected character "${rest[0]}" at character ${at + 1}`, at);
    }
    tokens.push({ type: 'end', text: '', at: text.length });
    return tokens;
};

const describe = (token) => (token.type === 'end' ? 'the end of the formula' : `"${token.text}"`);

export const parse = (source) => {
    if (typeof source === 'number' && Number.isFinite(source)) return { type: 'number', value: source };
    if (typeof source !== 'string') throw new ExprError('a formula must be text');
    if (source.trim() === '') throw new ExprError('the formula is empty');
    if (source.length > MAX_LENGTH) throw new ExprError(`the formula is longer than ${MAX_LENGTH} characters`);
    const tokens = tokenize(source);
    let position = 0;
    const peek = () => tokens[position];
    const take = () => tokens[position++];

    const additive = () => {
        let left = multiplicative();
        while (peek().type === '+' || peek().type === '-') {
            const op = take().type;
            left = { type: 'binary', op, left, right: multiplicative() };
        }
        return left;
    };
    const multiplicative = () => {
        let left = unary();
        while (peek().type === '*' || peek().type === '/' || peek().type === '%') {
            const op = take().type;
            left = { type: 'binary', op, left, right: unary() };
        }
        return left;
    };
    const unary = () => {
        if (peek().type === '-') { take(); return { type: 'negate', value: unary() }; }
        if (peek().type === '+') { take(); return unary(); }
        return power();
    };
    const power = () => {
        const base = primary();
        if (peek().type !== '^') return base;
        take();
        return { type: 'binary', op: '^', left: base, right: unary() };
    };
    const primary = () => {
        const token = take();
        if (token.type === 'number') return { type: 'number', value: token.value };
        if (token.type === 'name') {
            if (peek().type !== '(') return { type: 'name', name: token.text, at: token.at };
            const fn = FUNCTIONS[token.text];
            if (!fn) throw new ExprError(`unknown function "${token.text}" (known: ${FUNCTION_NAMES.join(', ')})`, token.at);
            take();
            const args = [];
            if (peek().type !== ')') {
                args.push(additive());
                while (peek().type === ',') { take(); args.push(additive()); }
            }
            const close = take();
            if (close.type !== ')') throw new ExprError(`expected "," or ")" in ${token.text}(…), found ${describe(close)}`, close.at);
            const [low, high] = fn.arity;
            if (args.length < low || args.length > high) {
                throw new ExprError(`${token.text}() takes ${low === high ? `exactly ${low} argument${low === 1 ? '' : 's'}` : `at least ${low}`}, not ${args.length}`, token.at);
            }
            return { type: 'call', name: token.text, args };
        }
        if (token.type === '(') {
            const inner = additive();
            const close = take();
            if (close.type !== ')') throw new ExprError(`expected ")" to close the "(" at character ${token.at + 1}, found ${describe(close)}`, close.at);
            return inner;
        }
        if (token.type === 'end') throw new ExprError('the formula ends too early: expected a number, name or "("', token.at);
        throw new ExprError(`unexpected ${describe(token)} at character ${token.at + 1}: expected a number, name or "("`, token.at);
    };

    const tree = additive();
    const rest = peek();
    if (rest.type !== 'end') {
        const previous = tokens[position - 1];
        const hint = previous && (previous.type === 'number' || previous.type === ')') && (rest.type === 'name' || rest.type === '(' || rest.type === 'number') ? ` (write ${previous.text} * ${rest.type === '(' ? '(…)' : rest.text} to multiply)` : '';
        throw new ExprError(`unexpected ${describe(rest)} at character ${rest.at + 1}${hint}`, rest.at);
    }
    return tree;
};

// Every name a tree reads, in the order they first appear
export const namesIn = (tree) => {
    const names = [];
    const walk = (node) => {
        if (node.type === 'name' && !names.includes(node.name)) names.push(node.name);
        if (node.type === 'negate') walk(node.value);
        if (node.type === 'binary') { walk(node.left); walk(node.right); }
        if (node.type === 'call') node.args.forEach(walk);
    };
    walk(tree);
    return names;
};

const BINARY = {
    '+': (a, b) => a + b,
    '-': (a, b) => a - b,
    '*': (a, b) => a * b,
    '/': (a, b) => a / b,
    '%': (a, b) => a % b,
    '^': (a, b) => a ** b,
};

// Evaluates a tree; `scope` maps names to numbers (only its own properties count)
export const evaluate = (tree, scope = {}) => {
    switch (tree.type) {
        case 'number': return tree.value;
        case 'name':
            if (!Object.hasOwn(scope, tree.name)) throw new ExprError(`unknown name "${tree.name}"`, tree.at);
            return Number(scope[tree.name]);
        case 'negate': return -evaluate(tree.value, scope);
        case 'binary': return BINARY[tree.op](evaluate(tree.left, scope), evaluate(tree.right, scope));
        case 'call': return FUNCTIONS[tree.name].apply(tree.args.map((arg) => evaluate(arg, scope)));
        default: throw new ExprError(`unknown node ${tree.type}`);
    }
};

// parse + evaluate in one go
export const calculate = (source, scope) => evaluate(parse(source), scope);
