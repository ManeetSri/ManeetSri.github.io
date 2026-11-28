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

// Merging two sorted lists with a dummy head and a tail pointer, matching the ll-merge-sorted lesson.
// Frames add `positions` ({ id: { col, row } }): the first list on the top row, the second below, the dummy between.
PROGRAMS.merge = {
    title: 'Merging two sorted lists with a dummy and a tail',
    defaults: { first: [1, 4, 6], second: [2, 3, 7, 8] },
    code: `func merge(_ first: ListNode?, _ second: ListNode?) -> ListNode? {
    let dummy = ListNode(0)
    var tail = dummy
    var a = first
    var b = second
    while let left = a, let right = b {
        if left.value <= right.value {
            tail.next = left
            a = left.next
        } else {
            tail.next = right
            b = right.next
        }
        tail = tail.next!
    }
    tail.next = a ?? b          // whatever is left is already sorted
    return dummy.next
}`,
    * run({ first, second }) {
        const nodes = [{ id: 0, value: 0 }, ...first.map((value, index) => ({ id: 1 + index, value })), ...second.map((value, index) => ({ id: 1 + first.length + index, value }))];
        const positions = { 0: { col: 0, row: 0.5 } };
        first.forEach((_, index) => { positions[1 + index] = { col: index + 1, row: 0 }; });
        second.forEach((_, index) => { positions[1 + first.length + index] = { col: index + 1, row: 1 }; });
        const next = { 0: null };
        first.forEach((_, index) => { next[1 + index] = index + 1 < first.length ? 2 + index : null; });
        second.forEach((_, index) => { next[1 + first.length + index] = index + 1 < second.length ? 2 + first.length + index : null; });
        let tail = 0;
        let a = first.length ? 1 : null;
        let b = second.length ? 1 + first.length : null;
        const merged = () => {
            const ids = [];
            for (let id = next[0]; id !== null && ids.length < nodes.length; id = next[id]) {
                ids.push(id);
                if (id === tail) break;
            }
            return Object.fromEntries(ids.map((id) => [id, 'found']));
        };
        const frame = (line, message, done = false) => ({ nodes, next: { ...next }, positions, pointers: done ? { dummy: 0 } : { dummy: 0, tail, a, b }, marks: merged(), line, message });
        yield frame(5, 'The dummy node gives the merged list a place to start, so the first link is no special case. tail is the last node of the merged list so far.');
        while (a !== null && b !== null) {
            const left = nodes[a];
            const right = nodes[b];
            if (left.value <= right.value) {
                next[tail] = a;
                a = next[a];
                yield frame(8, `${left.value} ≤ ${right.value}: link tail to ${left.value}, and a moves on${a === null ? ' to nil' : ` to ${nodes[a].value}`}.${left.value === right.value ? ' Taking the first list on ties keeps the merge stable.' : ''}`);
            } else {
                next[tail] = b;
                b = next[b];
                yield frame(11, `${right.value} < ${left.value}: link tail to ${right.value}, and b moves on${b === null ? ' to nil' : ` to ${nodes[b].value}`}.`);
            }
            tail = next[tail];
            yield frame(14, `tail moves to ${nodes[tail].value}, the end of the merged list.`);
        }
        const rest = a ?? b;
        next[tail] = rest;
        tail = null;
        yield frame(16, rest === null ? 'Both lists are used up.' : `One list is empty. The rest of the other, from ${nodes[rest].value}, is already sorted: link it on in one step.`);
        const order = [];
        for (let id = next[0]; id !== null; id = next[id]) order.push(nodes[id].value);
        yield { ...frame(17, `Return dummy.next: ${order.join(' -> ')} -> nil. No new nodes were made, only links changed: O(m + n) time, O(1) extra space.`, true), marks: Object.fromEntries(nodes.filter((node) => node.id !== 0).map((node) => [node.id, 'found'])) };
    },
};

export const LINKED_LIST_PROGRAMS = Object.keys(PROGRAMS);

export const linkedListProgram = (name) => {
    const program = PROGRAMS[name];
    if (!program) throw new Error(`Unknown linked-list program "${name}"`);
    return program;
};

export const linkedListFrames = (name, input = {}) => [...linkedListProgram(name).run({ ...linkedListProgram(name).defaults, ...input })];
