// Generated from src/dsa/content/lessons/queues/queue-streams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct MovingAverage {
    private var window: [Int]            // a ring of the last k values
    private var head = 0                 // the slot of the oldest value
    private var count = 0
    private var sum = 0

    init(size: Int) {
        window = Array(repeating: 0, count: size)
    }

    mutating func next(_ value: Int) -> Double {
        if count == window.count {
            sum -= window[head]                  // the oldest value leaves…
            window[head] = value                 // …and the new one takes its slot
            head = (head + 1) % window.count
        } else {
            window[(head + count) % window.count] = value
            count += 1
        }
        sum += value
        return Double(sum) / Double(count)
    }
}

var smoother = MovingAverage(size: 3)
for reading in [10, 20, 30, 40, 50, 0] {
    print(reading, "→", smoother.next(reading))
}
