// Generated from src/dsa/content/lessons/swift-generics/swift-sequence-iterator.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct PowersOfTwo: Sequence, IteratorProtocol {
    var current = 1

    mutating func next() -> Int? {
        defer { current *= 2 }
        return current
    }
}

print(Array(PowersOfTwo().prefix(6)))
for power in PowersOfTwo() {
    if power > 100 {
        break
    }
    print(power, terminator: " ")
}
print()
print(PowersOfTwo().first { $0 > 1_000 } ?? 0)
