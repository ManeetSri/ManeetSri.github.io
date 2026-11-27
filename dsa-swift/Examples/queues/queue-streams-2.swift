// Generated from src/dsa/content/lessons/queues/queue-streams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct HitCounter {
    private var times: [Int] = []        // a head-index queue of hit times, oldest first
    private var head = 0
    let window: Int

    init(window: Int) {
        self.window = window
    }

    mutating func hit(at time: Int) {
        times.append(time)
    }

    // Hits in the last `window` seconds, counting `time` itself: from time - window + 1 to time
    mutating func count(at time: Int) -> Int {
        while head < times.count && times[head] <= time - window {
            head += 1                    // too old: it will never count again
        }
        return times.count - head
    }
}

var logins = HitCounter(window: 60)
for time in [1, 2, 2, 30, 61] {
    logins.hit(at: time)
}
print(logins.count(at: 61))
print(logins.count(at: 62))
print(logins.count(at: 90))
print(logins.count(at: 121))
