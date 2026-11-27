// Generated from src/dsa/content/lessons/fast-swift/fs-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reallocations(appending count: Int, reserving: Bool) -> Int {
    var items: [Int] = []
    if reserving {
        items.reserveCapacity(count)
    }
    var changes = 0
    var capacity = items.capacity
    for value in 0..<count {
        items.append(value)
        if items.capacity != capacity {      // a new, bigger buffer: everything was copied
            changes += 1
            capacity = items.capacity
        }
    }
    return changes
}

print("reserved first:", reallocations(appending: 100_000, reserving: true))
print("not reserved, more than 10:", reallocations(appending: 100_000, reserving: false) > 10)
