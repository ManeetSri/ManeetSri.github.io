// Generated from src/dsa/content/lessons/randomised/rand-shuffle.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Shuffle [0, 1, 2] 60,000 times three ways, and count how often each of the 6 orders comes out
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 2026)

func fisherYates(_ items: inout [Int]) {
    for i in stride(from: items.count - 1, through: 1, by: -1) {
        items.swapAt(i, dice.roll(0...i))
    }
}

func anywhere(_ items: inout [Int]) {            // the bug: swap every position with any position
    for i in 0..<items.count {
        items.swapAt(i, dice.roll(0...(items.count - 1)))
    }
}

func neverStays(_ items: inout [Int]) {          // the other bug: j from 0..<i, never i itself
    for i in stride(from: items.count - 1, through: 1, by: -1) {
        items.swapAt(i, dice.roll(0...(i - 1)))
    }
}

let orders = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
print("order    ", orders.map { $0.map(String.init).joined() }.joined(separator: "   "))
for (name, shuffle) in [("correct  ", fisherYates), ("anywhere ", anywhere), ("0..<i    ", neverStays)] {
    var counts = [Int](repeating: 0, count: orders.count)
    for _ in 0..<60_000 {
        var items = [0, 1, 2]
        shuffle(&items)
        counts[orders.firstIndex(of: items)!] += 1
    }
    print(name, counts.map { String($0) }.joined(separator: " "))
}
