// Generated from src/dsa/content/lessons/design-structures/ds-hit-counter.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct RingHitCounter {
    private var slots: [(time: Int, hits: Int)]     // second t lives in slot t % window
    let window: Int

    init(window: Int) {
        self.window = window
        slots = Array(repeating: (time: -1, hits: 0), count: window)
    }

    mutating func record(_ hits: Int = 1, at time: Int) {
        let index = time % window
        if slots[index].time != time {             // the slot holds an older second: reuse it
            slots[index] = (time, 0)
        }
        slots[index].hits += hits
    }

    func count(at time: Int) -> Int {
        var total = 0
        for slot in slots where slot.time > time - window {   // still inside the window
            total += slot.hits
        }
        return total
    }
}

var counter = RingHitCounter(window: 5)
counter.record(at: 1)
counter.record(at: 2)
counter.record(4, at: 2)
counter.record(at: 6)                              // second 6 reuses second 1's slot
print(counter.count(at: 6))
print(counter.count(at: 7))
counter.record(1_000_000, at: 7)                   // a million hits: still one slot
print(counter.count(at: 7))
