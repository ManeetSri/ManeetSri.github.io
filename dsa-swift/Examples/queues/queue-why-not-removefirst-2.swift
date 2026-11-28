// Generated from src/dsa/content/lessons/queues/queue-why-not-removefirst.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Removes the first element the way Array does: every later element moves one place left
func dequeueCountingMoves(_ items: inout [Int]) -> Int {
    var moves = 0
    for index in items.indices.dropFirst() {
        items[index - 1] = items[index]
        moves += 1
    }
    items.removeLast()
    return moves
}

for n in [10, 100, 1_000] {
    var queue = Array(1...n)
    var moves = 0
    while !queue.isEmpty {
        moves += dequeueCountingMoves(&queue)
    }
    print("\(n) dequeues: \(moves) moves")
}
