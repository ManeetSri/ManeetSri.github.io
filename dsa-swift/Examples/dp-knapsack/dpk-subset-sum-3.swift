// Generated from src/dsa/content/lessons/dp-knapsack/dpk-subset-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Reachable subset sums as bits: bit s is 1 when some subset adds up to s
struct SumBits {
    var words: [UInt64]

    init(limit: Int) {
        words = Array(repeating: 0, count: limit / 64 + 1)
        words[0] = 1                                     // only sum 0 to begin with
    }

    func contains(_ s: Int) -> Bool {
        (words[s >> 6] >> UInt64(s & 63)) & 1 == 1
    }

    /// Adds x to every reachable sum at once: bits = bits | (bits << x), one word at a time
    mutating func add(_ x: Int) {
        let wordShift = x >> 6
        let bitShift = UInt64(x & 63)
        for i in stride(from: words.count - 1, through: wordShift, by: -1) {   // top down, like right to left
            var shifted = words[i - wordShift] << bitShift
            if bitShift > 0 && i - wordShift > 0 {
                shifted |= words[i - wordShift - 1] >> (64 - bitShift)          // bits carried from the word below
            }
            words[i] |= shifted
        }
    }
}

var small = SumBits(limit: 13)
for x in [3, 5, 9, 4] {
    small.add(x)
}
print((0...13).filter { small.contains($0) })

// A bigger split: 200 numbers from 1 to 300, compared with the Bool array
let numbers = (1...200).map { ($0 * 7_919) % 300 + 1 }
let half = numbers.reduce(0, +) / 2
var bits = SumBits(limit: half)
var reachable = Array(repeating: false, count: half + 1)
reachable[0] = true
for x in numbers {
    bits.add(x)
    for s in stride(from: half, through: x, by: -1) where reachable[s - x] {
        reachable[s] = true
    }
}
print("total \(numbers.reduce(0, +)), half \(half): bits say \(bits.contains(half)), Bools say \(reachable[half])")
print("cells updated per number: \(half + 1) Bools or \(bits.words.count) words")
