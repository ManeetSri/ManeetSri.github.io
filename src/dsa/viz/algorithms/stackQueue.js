// Stacks, queues and deques running a list of operations, one frame per operation.
// Operations are strings: "push 3", "pop", "peek" (stack); "enqueue 3", "dequeue", "peek" (queue);
// "pushFront 3", "pushBack 3", "popFront", "popBack" (deque).

const KINDS = {
    stack: {
        title: 'Stack: last in, first out',
        defaults: ['push 4', 'push 7', 'push 1', 'peek', 'pop', 'push 9', 'pop', 'pop'],
        apply(items, [op, arg]) {
            if (op === 'push') return { items: [...items, arg], message: `push(${arg}): it goes on top.`, touched: items.length };
            if (op === 'pop') return items.length ? { items: items.slice(0, -1), message: `pop() returns ${items.at(-1)}, the most recent push.`, removed: items.at(-1) } : { items, message: 'pop() on an empty stack returns nil.' };
            if (op === 'peek') return { items, message: items.length ? `peek() returns ${items.at(-1)} and leaves it there.` : 'peek() on an empty stack returns nil.', touched: items.length - 1 };
            throw new Error(`A stack can't "${op}"`);
        },
    },
    queue: {
        title: 'Queue: first in, first out',
        defaults: ['enqueue 4', 'enqueue 7', 'enqueue 1', 'dequeue', 'enqueue 9', 'peek', 'dequeue', 'dequeue'],
        apply(items, [op, arg]) {
            if (op === 'enqueue') return { items: [...items, arg], message: `enqueue(${arg}): it joins the back.`, touched: items.length };
            if (op === 'dequeue') return items.length ? { items: items.slice(1), message: `dequeue() returns ${items[0]}, the one waiting longest.`, removed: items[0] } : { items, message: 'dequeue() on an empty queue returns nil.' };
            if (op === 'peek') return { items, message: items.length ? `peek() returns ${items[0]}, the front.` : 'peek() on an empty queue returns nil.', touched: 0 };
            throw new Error(`A queue can't "${op}"`);
        },
    },
    deque: {
        title: 'Deque: add and remove at both ends',
        defaults: ['pushBack 4', 'pushBack 7', 'pushFront 1', 'pushFront 9', 'popBack', 'popFront', 'pushBack 3'],
        apply(items, [op, arg]) {
            if (op === 'pushBack') return { items: [...items, arg], message: `pushBack(${arg}).`, touched: items.length };
            if (op === 'pushFront') return { items: [arg, ...items], message: `pushFront(${arg}).`, touched: 0 };
            if (op === 'popBack') return items.length ? { items: items.slice(0, -1), message: `popBack() returns ${items.at(-1)}.`, removed: items.at(-1) } : { items, message: 'popBack() on an empty deque returns nil.' };
            if (op === 'popFront') return items.length ? { items: items.slice(1), message: `popFront() returns ${items[0]}.`, removed: items[0] } : { items, message: 'popFront() on an empty deque returns nil.' };
            throw new Error(`A deque can't "${op}"`);
        },
    },
};

export const STACK_QUEUE_KINDS = Object.keys(KINDS);

export const stackQueueTitle = (kind) => KINDS[kind].title;

const parse = (operation) => {
    const [op, value] = operation.trim().split(/\s+/);
    return [op, value === undefined ? undefined : Number(value)];
};

export const stackQueueFrames = (kind, operations) => {
    const spec = KINDS[kind];
    if (!spec) throw new Error(`Unknown kind "${kind}"`);
    let items = [];
    const frames = [{ items, operation: null, message: `An empty ${kind}.` }];
    (operations ?? spec.defaults).forEach((operation) => {
        const result = spec.apply(items, parse(operation));
        items = result.items;
        frames.push({ items, operation, message: result.message, touched: result.touched, removed: result.removed });
    });
    return frames;
};
