// Generated from src/dsa/content/lessons/randomised/rand-cache-policies.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Belady's anomaly: with FIFO, a bigger cache can get fewer hits
func fifoHits(_ trace: [Int], capacity: Int) -> Int {
    var queue: [Int] = []                        // oldest first
    var hitCount = 0
    for key in trace {
        if queue.contains(key) {
            hitCount += 1                        // FIFO ignores hits: the order doesn't change
        } else {
            if queue.count == capacity { queue.removeFirst() }
            queue.append(key)
        }
    }
    return hitCount
}

func lruHits(_ trace: [Int], capacity: Int) -> Int {
    var order: [Int] = []                        // least recently used first
    var hitCount = 0
    for key in trace {
        if let index = order.firstIndex(of: key) {
            hitCount += 1
            order.remove(at: index)
        } else if order.count == capacity {
            order.removeFirst()
        }
        order.append(key)
    }
    return hitCount
}

let trace = [1, 2, 3, 4, 1, 2, 5, 1, 2, 3, 4, 5]
for capacity in 3...4 {
    print("capacity \(capacity): FIFO \(fifoHits(trace, capacity: capacity)) hits, LRU \(lruHits(trace, capacity: capacity)) hits")
}
