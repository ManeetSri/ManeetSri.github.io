// Generated from src/dsa/content/lessons/advanced-structures/as-bloom-sketch.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

func fnv1a(_ text: String) -> UInt64 {
    var hash: UInt64 = 0xcbf2_9ce4_8422_2325
    for byte in text.utf8 {
        hash ^= UInt64(byte)
        hash = hash &* 0x0000_0100_0000_01B3
    }
    return hash
}

func mix(_ x: UInt64) -> UInt64 {
    var z = x
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
}

struct CountMinSketch {
    let width: Int
    let depth: Int
    private var counters: [[Int]]                // depth rows of width counters
    private(set) var total = 0

    init(width: Int, depth: Int) {
        self.width = width
        self.depth = depth
        counters = Array(repeating: Array(repeating: 0, count: width), count: depth)
    }

    // Each row has its own hash: the item's hash mixed with the row number
    private func column(of item: String, row: Int) -> Int {
        Int(mix(fnv1a(item) &+ UInt64(row)) % UInt64(width))
    }

    mutating func add(_ item: String) {
        for row in 0..<depth {
            counters[row][column(of: item, row: row)] += 1
        }
        total += 1
    }

    // Every row overcounts (other items share its counter), never undercounts: take the smallest
    func estimate(_ item: String) -> Int {
        (0..<depth).map { counters[$0][column(of: item, row: $0)] }.min()!
    }
}

// A stream of 10,000 hashtags: a few popular ones, and a long tail seen once or twice
var stream: [String] = []
for (tag, count) in [("swift", 1_200), ("ios", 900), ("wwdc", 600), ("xcode", 300), ("swiftui", 150)] {
    stream += Array(repeating: tag, count: count)
}
var generator = SeededGenerator(state: 8)
while stream.count < 10_000 {
    stream.append("tag\(generator.next() % 5_000)")
}
for i in stream.indices.reversed() {             // Fisher–Yates shuffle with the seeded generator
    stream.swapAt(i, Int(generator.next() % UInt64(i + 1)))
}

var sketch = CountMinSketch(width: 272, depth: 5)
var exact: [String: Int] = [:]                   // only for checking; a real stream can't afford it
var trending: [String] = []                      // tags whose estimate reached 200, in order
var reported: Set<String> = []
for tag in stream {
    sketch.add(tag)
    exact[tag, default: 0] += 1
    if sketch.estimate(tag) >= 200 && reported.insert(tag).inserted {
        trending.append(tag)
    }
}
for tag in ["swift", "xcode", "swiftui", "tag7", "tag4242"] {
    print(tag, "exact:", exact[tag] ?? 0, "estimate:", sketch.estimate(tag))
}
let worst = exact.keys.map { sketch.estimate($0) - exact[$0]! }.max()!
print("distinct tags:", exact.count, " largest overcount:", worst, " 1% of the stream:", sketch.total / 100)
print("trending:", trending)
