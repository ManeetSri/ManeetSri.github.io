// Recursive calls as frames: every call and every return is a step. Each frame has a snapshot of the
// call tree (with the value each finished call returned), the call stack, the Swift line and a message.

const FUNCTIONS = {
    factorial: {
        code: `func factorial(_ n: Int) -> Int {
    if n <= 1 {
        return 1
    }
    return n * factorial(n - 1)
}`,
        label: ([n]) => `factorial(${n})`,
        isBase: ([n]) => n <= 1,
        base: () => 1,
        children: ([n]) => [[n - 1]],
        combine: ([n], [child]) => ({ value: n * child, detail: `${n} × ${child}` }),
        lines: { call: 1, base: 3, combine: 5 },
        limits: { min: 0, max: 8 },
    },
    fibonacciMemo: {
        code: `var memo: [Int: Int] = [:]

func fibonacci(_ n: Int) -> Int {
    if let known = memo[n] {
        return known
    }
    if n < 2 {
        return n
    }
    let result = fibonacci(n - 1) + fibonacci(n - 2)
    memo[n] = result
    return result
}`,
        label: ([n]) => `fib(${n})`,
        isBase: ([n]) => n < 2,
        base: ([n]) => n,
        children: ([n]) => [[n - 1], [n - 2]],
        combine: (_, [a, b]) => ({ value: a + b, detail: `${a} + ${b}` }),
        lines: { call: 3, cached: 5, base: 8, combine: 10 },
        limits: { min: 0, max: 10 },
        memo: true,
    },
    fibonacci: {
        code: `func fibonacci(_ n: Int) -> Int {
    if n < 2 {
        return n
    }
    return fibonacci(n - 1) + fibonacci(n - 2)
}`,
        label: ([n]) => `fib(${n})`,
        isBase: ([n]) => n < 2,
        base: ([n]) => n,
        children: ([n]) => [[n - 1], [n - 2]],
        combine: (_, [a, b]) => ({ value: a + b, detail: `${a} + ${b}` }),
        lines: { call: 1, base: 3, combine: 5 },
        limits: { min: 0, max: 6 },
    },
    power: {
        code: `func power(_ base: Int, _ exponent: Int) -> Int {
    if exponent == 0 {
        return 1
    }
    return base * power(base, exponent - 1)
}`,
        label: ([base, exponent]) => `power(${base}, ${exponent})`,
        isBase: ([, exponent]) => exponent === 0,
        base: () => 1,
        children: ([base, exponent]) => [[base, exponent - 1]],
        combine: ([base], [child]) => ({ value: base * child, detail: `${base} × ${child}` }),
        lines: { call: 1, base: 3, combine: 5 },
        limits: { min: 0, max: 8 },
    },
    sumDigits: {
        code: `func sumOfDigits(_ n: Int) -> Int {
    if n < 10 {
        return n
    }
    return n % 10 + sumOfDigits(n / 10)
}`,
        label: ([n]) => `sumOfDigits(${n})`,
        isBase: ([n]) => n < 10,
        base: ([n]) => n,
        children: ([n]) => [[Math.floor(n / 10)]],
        combine: ([n], [child]) => ({ value: (n % 10) + child, detail: `${n % 10} + ${child}` }),
        lines: { call: 1, base: 3, combine: 5 },
        limits: { min: 0, max: 99999 },
    },
};

export const RECURSIVE_FUNCTIONS = Object.keys(FUNCTIONS);

export const recursionCode = (name) => FUNCTIONS[name].code;

export const recursionLimits = (name) => FUNCTIONS[name].limits;

export const recursionFrames = (name, args) => {
    const fn = FUNCTIONS[name];
    if (!fn) throw new Error(`Unknown recursive function "${name}"`);
    const nodes = [];
    const stack = [];
    const frames = [];
    const cache = new Map();

    const snapshot = (line, message) => frames.push({
        nodes: nodes.map((node) => ({ ...node, state: node.done ? 'done' : stack.at(-1) === node.id ? 'active' : 'waiting' })),
        stack: stack.map((id) => nodes[id].label),
        line,
        message,
    });

    const call = (callArgs, parent) => {
        const node = { id: nodes.length, parent, label: fn.label(callArgs), value: null, done: false };
        nodes.push(node);
        stack.push(node.id);
        snapshot(fn.lines.call, `Call ${node.label}. The stack is now ${stack.length} deep.`);

        let value;
        const key = callArgs.join(',');
        if (fn.memo && cache.has(key)) {
            value = cache.get(key);
            node.value = value;
            node.cached = true;
            snapshot(fn.lines.cached, `${node.label} is already in the memo: return ${value} at once, with no further calls.`);
        } else if (fn.isBase(callArgs)) {
            value = fn.base(callArgs);
            node.value = value;
            snapshot(fn.lines.base, `${node.label} is a base case: it returns ${value} without calling itself.`);
        } else {
            const childValues = fn.children(callArgs).map((childArgs) => call(childArgs, node.id));
            const { value: combined, detail } = fn.combine(callArgs, childValues);
            value = combined;
            node.value = value;
            snapshot(fn.lines.combine, `Back in ${node.label}: ${detail} = ${value}.${fn.memo ? ` Save it in the memo.` : ''}`);
        }
        if (fn.memo) cache.set(key, value);
        node.done = true;
        stack.pop();
        return value;
    };

    const result = call(args, null);
    frames.push({ ...frames.at(-1), nodes: frames.at(-1).nodes.map((node) => ({ ...node, state: 'done' })), stack: [], message: `Done: ${fn.label(args)} = ${result}, after ${nodes.length} call${nodes.length === 1 ? '' : 's'}.` });
    return frames;
};

// Tidy enough for small trees: leaves are spaced evenly left to right, parents sit above their children
export const layoutTree = (nodes) => {
    const children = new Map(nodes.map((node) => [node.id, []]));
    nodes.forEach((node) => node.parent !== null && children.get(node.parent).push(node.id));
    const position = new Map();
    let nextLeaf = 0;
    const place = (id, depth) => {
        const kids = children.get(id);
        if (!kids.length) {
            position.set(id, { x: nextLeaf, depth });
            nextLeaf += 1;
        } else {
            kids.forEach((kid) => place(kid, depth + 1));
            const xs = kids.map((kid) => position.get(kid).x);
            position.set(id, { x: (Math.min(...xs) + Math.max(...xs)) / 2, depth });
        }
    };
    if (nodes.length) place(0, 0);
    return { position, width: Math.max(1, nextLeaf), depth: Math.max(0, ...[...position.values()].map((p) => p.depth)) + 1 };
};
