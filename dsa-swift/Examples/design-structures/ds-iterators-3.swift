// Generated from src/dsa/content/lessons/design-structures/ds-iterators.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct ZigzagIterator: IteratorProtocol, Sequence {
    private var turns: [IndexingIterator<[Int]>]    // iterators still running, in turn order
    private var head = 0                           // a head-index queue, as in M27

    init(_ lists: [[Int]]) {
        turns = lists.map { $0.makeIterator() }
    }

    mutating func next() -> Int? {
        while head < turns.count {
            var current = turns[head]
            head += 1
            if let value = current.next() {
                turns.append(current)                // back of the line for its next turn
                return value
            }
            // used up: it isn't put back
        }
        return nil
    }
}

print(Array(ZigzagIterator([[1, 2, 3], [10], [], [20, 21, 22, 23]])))
for value in ZigzagIterator([[7, 8], [100, 200, 300]]) {
    print(value, terminator: " ")
}
print()
