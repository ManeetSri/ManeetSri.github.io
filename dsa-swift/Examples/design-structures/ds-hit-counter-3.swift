// Generated from src/dsa/content/lessons/design-structures/ds-hit-counter.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(below limit: Int) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Int((state >> 33) % UInt64(limit))
    }
}

/// The design under test: the index of the first version later than `time`
func firstLater(in history: [(time: Int, value: Int)], than time: Int, buggy: Bool) -> Int {
    var low = 0
    var high = history.count
    while low < high {
        let middle = low + (high - low) / 2
        let notLater = buggy ? history[middle].time < time : history[middle].time <= time
        if notLater { low = middle + 1 } else { high = middle }
    }
    return low
}

func mismatches(buggy: Bool) -> Int {
    var dice = Dice(seed: 7)
    var store: [Int: [(time: Int, value: Int)]] = [:]      // the design
    var log: [(key: Int, time: Int, value: Int)] = []      // the model: every set, in order
    var now = 0
    var wrong = 0
    for step in 0..<2_000 {
        let key = dice.roll(below: 4)
        if dice.roll(below: 2) == 0 {
            now += 1 + dice.roll(below: 3)
            store[key, default: []].append((now, step))
            log.append((key, now, step))
        } else {
            let asked = dice.roll(below: now + 3)
            let expected = log.last { $0.key == key && $0.time <= asked }?.value   // slow but obviously right
            let history = store[key] ?? []
            let later = firstLater(in: history, than: asked, buggy: buggy)
            let answer = later == 0 ? nil : history[later - 1].value
            if answer != expected { wrong += 1 }
        }
    }
    return wrong
}

print("correct search:", mismatches(buggy: false), "mismatches")
print("< instead of <=:", mismatches(buggy: true), "mismatches")
