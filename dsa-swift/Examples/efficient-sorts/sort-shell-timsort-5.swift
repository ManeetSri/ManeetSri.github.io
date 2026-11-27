// Generated from src/dsa/content/lessons/efficient-sorts/sort-shell-timsort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Comparisons Swift's own sort makes on 10,000 values arranged in different ways
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ limit: Int) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Int((state >> 33) % UInt64(limit))
    }
}

func comparisonsToSort(_ numbers: [Int]) -> Int {
    var comparisons = 0
    _ = numbers.sorted { a, b in
        comparisons += 1
        return a < b
    }
    return comparisons
}

let n = 10_000
var dice = Dice(seed: 4)
let sorted = Array(0..<n)
let inputs = [
    ("sorted", sorted),
    ("sorted, then 10 new values", Array(sorted.dropLast(10)) + (0..<10).map { _ in dice.roll(n) }),
    ("4 sorted blocks", (0..<n).map { ($0 % 2_500) * 4 + $0 / 2_500 }),
    ("reversed", Array(sorted.reversed())),
    ("random", (0..<n).map { _ in dice.roll(n) }),
]
for (name, input) in inputs {
    print("\(name): \(comparisonsToSort(input))")
}
