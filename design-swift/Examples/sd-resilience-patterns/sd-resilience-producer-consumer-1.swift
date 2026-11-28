// Generated from src/dsa/design/content/lessons/sd-resilience-patterns/sd-resilience-producer-consumer.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Each second, 8 photos arrive and the workers finish 5. What does the queue do about the other 3?
enum WhenFull {
    case unbounded
    case dropNew(capacity: Int)
    case producerWaits(capacity: Int)
}

func simulate(_ policy: WhenFull, seconds: Int) -> String {
    var queued = 0
    var lost = 0       // dropped for good
    var behind = 0     // still in the photo library, not yet read by the producer
    var sizes: [Int] = []
    for _ in 1...seconds {
        var arriving = 8 + behind
        behind = 0
        switch policy {
        case .unbounded:
            break
        case .dropNew(let capacity):
            lost += max(0, queued + arriving - capacity)
            arriving = min(arriving, capacity - queued)
        case .producerWaits(let capacity):
            behind = max(0, queued + arriving - capacity)
            arriving = min(arriving, capacity - queued)
        }
        queued += arriving
        sizes.append(queued)
        queued -= min(queued, 5)
    }
    return "queue \(sizes), lost \(lost), not yet read \(behind)"
}

print("Unbounded:       ", simulate(.unbounded, seconds: 5))
print("Drop new (10):   ", simulate(.dropNew(capacity: 10), seconds: 5))
print("Producer waits:  ", simulate(.producerWaits(capacity: 10), seconds: 5))
