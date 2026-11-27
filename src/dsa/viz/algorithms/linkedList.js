// Linked-list algorithms as frames: the nodes stay in place and only their `next` arrows and the named
// pointers move. Frame: { nodes: [{ id, value }], next: { id: id | null }, pointers: { name: id | null }, marks, line, message }.

const PROGRAMS = {
    reverse: {
        title: 'Reversing a linked list',
        defaults: { values: [1, 2, 3, 4, 5] },
        code: `func reverse(_ head: ListNode?) -> ListNode? {
    var previous: ListNode? = nil
    var current = head
    while let node = current {
        let next = node.next
        node.next = previous
        previous = node
        current = next
    }
    return previous
}`,
        * run({ values }) {
            const nodes = values.map((value, id) => ({ id, value }));
            const next = Object.fromEntries(nodes.map((node) => [node.id, node.id + 1 < nodes.length ? node.id + 1 : null]));
            let previous = null;
            let current = nodes.length ? 0 : null;
            const frame = (line, message, extra = {}) => ({ nodes, next: { ...next }, pointers: { previous, current, ...extra }, marks: {}, line, message });
            yield frame(3, 'previous starts as nil, current at the head.');
            while (current !== null) {
                const after = next[current];
                yield frame(5, `Remember the node after ${nodes[current].value} in next, before we lose it.`, { next: after });
                next[current] = previous;
                yield frame(6, `Point ${nodes[current].value} back at ${previous === null ? 'nil' : nodes[previous].value}.`, { next: after });
                previous = current;
                current = after;
                yield frame(8, 'Step forward: previous and current both move one node on.');
            }
            yield { ...frame(10, `current is nil. previous (${previous === null ? 'nil' : nodes[previous].value}) is the new head.`), pointers: { head: previous } };
        },
    },
    middle: {
        title: 'Finding the middle with fast and slow pointers',
        defaults: { values: [3, 8, 1, 9, 4, 7, 6] },
        code: `func middle(_ head: ListNode?) -> ListNode? {
    var slow = head
    var fast = head
    while fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
    }
    return slow
}`,
        * run({ values }) {
            const nodes = values.map((value, id) => ({ id, value }));
            const next = Object.fromEntries(nodes.map((node) => [node.id, node.id + 1 < nodes.length ? node.id + 1 : null]));
            let slow = 0;
            let fast = 0;
            const frame = (line, message) => ({ nodes, next, pointers: { slow, fast }, marks: {}, line, message });
            yield frame(3, 'Both pointers start at the head.');
            while (fast !== null && next[fast] !== null) {
                slow = next[slow];
                fast = next[next[fast]] ?? null;
                yield frame(6, `slow moves one step, fast moves two.${fast === null ? ' fast ran off the end.' : ''}`);
            }
            yield { ...frame(8, `fast can’t take two more steps, so slow (${nodes[slow].value}) is the middle.`), marks: { [slow]: 'found' } };
        },
    },
    cycle: {
        title: 'Detecting a cycle with Floyd’s tortoise and hare',
        defaults: { values: [1, 2, 3, 4, 5, 6], loopTo: 2 },
        code: `func hasCycle(_ head: ListNode?) -> Bool {
    var slow = head
    var fast = head
    while fast?.next != nil {
        slow = slow?.next
        fast = fast?.next?.next
        if slow === fast {
            return true
        }
    }
    return false
}`,
        * run({ values, loopTo }) {
            const nodes = values.map((value, id) => ({ id, value }));
            const next = Object.fromEntries(nodes.map((node) => [node.id, node.id + 1 < nodes.length ? node.id + 1 : (loopTo ?? null)]));
            let slow = 0;
            let fast = 0;
            const frame = (line, message, marks = {}) => ({ nodes, next, pointers: { slow, fast }, marks, line, message });
            yield frame(3, loopTo === null ? 'This list ends in nil. Both pointers start at the head.' : `The last node points back to ${nodes[loopTo].value}: a cycle. Both pointers start at the head.`);
            while (fast !== null && next[fast] !== null) {
                slow = next[slow];
                fast = next[next[fast]] ?? null;
                if (slow === fast) {
                    yield frame(7, `slow and fast meet at ${nodes[slow].value}: inside a cycle, the faster pointer always catches up.`, { [slow]: 'found' });
                    return;
                }
                yield frame(6, 'slow moves one step, fast moves two.');
            }
            yield frame(11, 'fast reached the end, so there is no cycle.');
        },
    },
};

export const LINKED_LIST_PROGRAMS = Object.keys(PROGRAMS);

export const linkedListProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown linked-list program "${name}"`);
    return program;
};

export const linkedListFrames = (name, input = {}) => [...linkedListProgram(name).run({ ...linkedListProgram(name).defaults, ...input })];
