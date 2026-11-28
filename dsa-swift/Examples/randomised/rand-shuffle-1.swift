// Generated from src/dsa/content/lessons/randomised/rand-shuffle.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Fisher–Yates: fill the last slot from everything, the next-to-last from what's left, and so on
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 67)

func fisherYates(_ items: inout [String]) {
    guard items.count > 1 else { return }
    for i in stride(from: items.count - 1, through: 1, by: -1) {
        let j = dice.roll(0...i)             // any position from 0 to i, including i itself
        items.swapAt(i, j)
    }
}

var deck = ["A", "B", "C", "D", "E"]
for _ in 1...4 {
    fisherYates(&deck)
    print(deck)
}
