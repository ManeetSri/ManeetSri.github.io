// Generated from src/dsa/content/lessons/randomised/rand-monte-carlo.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Freivalds' check: is A × B == C? Test with random 0/1 vectors in O(n²) instead of multiplying in O(n³)
struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {          // SplitMix64
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

func times(_ m: [[Int]], _ v: [Int]) -> [Int] {        // matrix × vector: O(n²)
    m.map { row in zip(row, v).reduce(0) { $0 + $1.0 * $1.1 } }
}

/// One trial: false means "definitely not equal"; true means "probably equal"
func trial(_ a: [[Int]], _ b: [[Int]], _ c: [[Int]], using generator: inout SeededGenerator) -> Bool {
    let r = (0..<b.count).map { _ in Int(generator.next() & 1) }    // a random vector of 0s and 1s
    return times(a, times(b, r)) == times(c, r)                       // A(Br) against Cr
}

func probablyEqual(_ a: [[Int]], _ b: [[Int]], _ c: [[Int]], trials: Int, using generator: inout SeededGenerator) -> Bool {
    for _ in 0..<trials where !trial(a, b, c, using: &generator) {
        return false                                                  // a witness: certainly different
    }
    return true
}

let a = [[2, 0, 1], [1, 3, 0], [0, 1, 4]]
let b = [[1, 2, 0], [0, 1, 1], [3, 0, 2]]
let right = [[5, 4, 2], [1, 5, 3], [12, 1, 9]]        // the true product
var wrong = right
wrong[1][2] = 4                                        // one entry off by one

var generator = SeededGenerator(seed: 99)
print("right product:", probablyEqual(a, b, right, trials: 20, using: &generator))
print("wrong product:", probablyEqual(a, b, wrong, trials: 20, using: &generator))

var caught = 0
for _ in 0..<1_000 where !trial(a, b, wrong, using: &generator) {
    caught += 1
}
print("single trials that caught the wrong product: \(caught) of 1000")
