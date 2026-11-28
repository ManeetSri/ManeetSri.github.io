// Generated from src/dsa/content/lessons/randomised/rand-reservoir.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Reservoir sampling with k = 1: keep the ith item with probability 1/i
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 15)

/// One item chosen uniformly from a stream, in one pass, remembering a single item
func pickOne(from stream: [String]) -> String? {
    var kept: String? = nil
    var seen = 0
    for item in stream {
        seen += 1
        if dice.roll(1...seen) == 1 {         // probability 1/seen
            kept = item
        }
    }
    return kept
}

let lines = ["GET /", "GET /about", "POST /login", "GET /cart", "GET /help"]
var counts: [String: Int] = [:]
for _ in 0..<100_000 {
    counts[pickOne(from: lines)!, default: 0] += 1
}
for line in lines {
    print(line, counts[line]!)
}
