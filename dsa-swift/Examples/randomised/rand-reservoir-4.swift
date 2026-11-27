// Generated from src/dsa/content/lessons/randomised/rand-reservoir.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Weighted picks: prefix sums turn the weights into stretches of a number line, binary search finds one
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 8)

let weights = [5, 1, 3, 1]
var prefix: [Int] = []                    // prefix[i] = weights[0] + ... + weights[i]
var running = 0
for weight in weights {
    running += weight
    prefix.append(running)
}
print("prefix sums:", prefix)

/// The first index whose prefix sum is greater than r
func pick() -> Int {
    let r = dice.roll(0...(running - 1))  // a point on the line 0..<total
    var low = 0
    var high = prefix.count - 1
    while low < high {
        let mid = (low + high) / 2
        if prefix[mid] > r { high = mid } else { low = mid + 1 }
    }
    return low
}

var counts = [Int](repeating: 0, count: weights.count)
for _ in 0..<100_000 {
    counts[pick()] += 1
}
print("picks:", counts)
