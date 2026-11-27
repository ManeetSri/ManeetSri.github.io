// Generated from src/dsa/content/lessons/advanced-structures/as-sparse-bitset.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A set of the numbers 0..<capacity: one bit each, packed into UInt64 words
struct BitSet {
    let capacity: Int
    private(set) var words: [UInt64]

    init(capacity: Int) {
        self.capacity = capacity
        words = Array(repeating: 0, count: (capacity + 63) / 64)
    }

    mutating func insert(_ x: Int) {
        words[x >> 6] |= 1 << (x & 63)
    }

    func contains(_ x: Int) -> Bool {
        words[x >> 6] & (1 << (x & 63)) != 0
    }

    // Whole-set operations work on 64 numbers at a time
    func union(_ other: BitSet) -> BitSet { combined(with: other) { $0 | $1 } }
    func intersection(_ other: BitSet) -> BitSet { combined(with: other) { $0 & $1 } }
    func subtracting(_ other: BitSet) -> BitSet { combined(with: other) { $0 & ~$1 } }

    private func combined(with other: BitSet, _ operation: (UInt64, UInt64) -> UInt64) -> BitSet {
        var result = self
        for i in words.indices {
            result.words[i] = operation(words[i], other.words[i])
        }
        return result
    }

    var count: Int {
        words.reduce(0) { $0 + $1.nonzeroBitCount }
    }

    // The members in increasing order: jump straight from one set bit to the next
    var elements: [Int] {
        var result: [Int] = []
        for (i, word) in words.enumerated() {
            var rest = word
            while rest != 0 {
                result.append(i * 64 + rest.trailingZeroBitCount)
                rest &= rest - 1                 // clear the lowest set bit
            }
        }
        return result
    }

    // Every member x becomes x + s; members pushed past capacity fall off
    func shiftedUp(by s: Int) -> BitSet {
        var result = BitSet(capacity: capacity)
        let wordShift = s >> 6
        let bitShift = s & 63
        for i in stride(from: words.count - 1, through: wordShift, by: -1) {
            var word = words[i - wordShift] << bitShift
            if i - wordShift > 0 {
                word |= words[i - wordShift - 1] >> (64 - bitShift)   // bits carried from below
            }
            result.words[i] = word
        }
        let spare = words.count * 64 - capacity  // bits past the end must stay 0
        if spare > 0 {
            result.words[words.count - 1] &= ~UInt64(0) >> spare
        }
        return result
    }
}

// Which of 10,000 users liked post A, post B?
var likedA = BitSet(capacity: 10_000)
var likedB = BitSet(capacity: 10_000)
for user in stride(from: 0, to: 10_000, by: 3) { likedA.insert(user) }
for user in stride(from: 0, to: 10_000, by: 5) { likedB.insert(user) }
print("A:", likedA.count, " B:", likedB.count, " both:", likedA.intersection(likedB).count,
      " either:", likedA.union(likedB).count, " A only:", likedA.subtracting(likedB).count)
print("first users who liked both:", Array(likedA.intersection(likedB).elements.prefix(5)))
print("words per set:", likedA.words.count, "instead of", likedA.count, "Ints in an array")

// Subset sums: which totals can some of these weights make? Each weight shifts and ORs the set.
var reachable = BitSet(capacity: 31)
reachable.insert(0)
for weight in [3, 5, 7, 11] {
    reachable = reachable.union(reachable.shiftedUp(by: weight))
}
print("sums up to 30:", reachable.elements)

var wide = BitSet(capacity: 200)
wide.insert(60)
wide.insert(130)
print("60 and 130 shifted up by 10:", wide.shiftedUp(by: 10).elements, " by 70:", wide.shiftedUp(by: 70).elements)
