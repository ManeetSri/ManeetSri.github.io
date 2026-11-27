// Generated from src/dsa/content/lessons/bits/bits-gray-code-bitsets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct BitSet {
    private var words: [UInt64]

    init(capacity: Int) {
        words = Array(repeating: 0, count: (capacity + 63) / 64)
    }

    mutating func insert(_ x: Int) {
        words[x >> 6] |= 1 << (x & 63)
    }

    func contains(_ x: Int) -> Bool {
        words[x >> 6] & (1 << (x & 63)) != 0
    }

    var count: Int {
        words.reduce(0) { $0 + $1.nonzeroBitCount }
    }
}

var multiples = BitSet(capacity: 200)
for x in stride(from: 0, to: 200, by: 3) {
    multiples.insert(x)
}
print(multiples.count, multiples.contains(99), multiples.contains(100))
