// Generated from src/dsa/content/lessons/queues/queue-ring-buffer.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct RecentLog {
    private var slots: [String?]
    private var head = 0
    private var count = 0

    init(capacity: Int) {
        slots = Array(repeating: nil, count: capacity)
    }

    mutating func record(_ line: String) {
        if count == slots.count {
            slots[head] = line                       // overwrite the oldest…
            head = (head + 1) % slots.count          // …and the next oldest becomes the front
        } else {
            slots[(head + count) % slots.count] = line
            count += 1
        }
    }

    var lines: [String] {                            // oldest first
        (0..<count).compactMap { slots[(head + $0) % slots.count] }
    }
}

var log = RecentLog(capacity: 3)
for event in ["launch", "login", "open feed", "like", "crash"] {
    log.record(event)
    print(log.lines)
}
