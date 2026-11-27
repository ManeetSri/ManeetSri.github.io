// Generated from src/dsa/content/lessons/design-structures/ds-iterators.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct PeekingIterator<Base: IteratorProtocol>: IteratorProtocol {
    private var base: Base
    private var buffered: Base.Element?     // fetched early by peek(), not yet handed out
    private var hasBuffered = false

    init(_ base: Base) {
        self.base = base
    }

    mutating func peek() -> Base.Element? {
        if !hasBuffered {
            buffered = base.next()           // pull one element early, only once
            hasBuffered = true
        }
        return buffered
    }

    mutating func next() -> Base.Element? {
        guard hasBuffered else { return base.next() }
        hasBuffered = false
        let element = buffered
        buffered = nil                       // don't keep it alive
        return element
    }
}

// Run-length encoding: peek says whether the next reading continues the current run
var readings = PeekingIterator([3, 3, 5, 7, 7, 7, 3].makeIterator())
var runs: [String] = []
while let value = readings.next() {
    var length = 1
    while readings.peek() == value {
        _ = readings.next()
        length += 1
    }
    runs.append("\(value)×\(length)")
}
print(runs.joined(separator: " "))

var letters = PeekingIterator("ab".makeIterator())
print(letters.peek() ?? "-", letters.peek() ?? "-", letters.next() ?? "-", letters.next() ?? "-", letters.peek() ?? "-")
