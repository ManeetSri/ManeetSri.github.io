// Generated from src/dsa/content/lessons/randomised/rand-reservoir.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Reservoir sampling with k items: the ith item replaces a random slot with probability k/i
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 3)

func sample(_ k: Int, from stream: some Sequence<Int>) -> [Int] {
    var reservoir: [Int] = []
    var seen = 0
    for item in stream {
        seen += 1
        if reservoir.count < k {
            reservoir.append(item)                   // the first k fill the reservoir
        } else {
            let j = dice.roll(0...(seen - 1))        // uniform over the seen items' positions
            if j < k {
                reservoir[j] = item                  // probability k / seen: replace slot j
            }
        }
    }
    return reservoir
}

print("one sample:", sample(3, from: 1...10))
var picked = [Int](repeating: 0, count: 11)
for _ in 0..<100_000 {
    for item in sample(3, from: 1...10) {
        picked[item] += 1
    }
}
print("times each of 1...10 was picked:")
print(Array(picked[1...]))
