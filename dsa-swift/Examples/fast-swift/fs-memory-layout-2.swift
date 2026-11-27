// Generated from src/dsa/content/lessons/fast-swift/fs-memory-layout.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var queue: [Int] = []
for round in 1...3 {
    queue.removeAll(keepingCapacity: true)
    let before = queue.capacity
    for cell in 0..<1_000 {
        queue.append(cell)
    }
    print("round \(round): needed a bigger buffer?", queue.capacity != before)
}

queue.removeAll()        // keepingCapacity defaults to false
print(queue.capacity)
