// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick-pivots.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A tiny seeded generator, so this example prints the same thing every run.
// Real code would write Int.random(in: low...high) instead.
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 42)
var comparisons = 0

/// Lomuto partition, after moving the chosen pivot to the end
func partition(_ items: inout [Int], _ low: Int, _ high: Int, pivotIndex: Int) -> Int {
    items.swapAt(pivotIndex, high)
    let pivot = items[high]
    var boundary = low
    for j in low..<high {
        comparisons += 1
        if items[j] < pivot {
            items.swapAt(boundary, j)
            boundary += 1
        }
    }
    items.swapAt(boundary, high)
    return boundary
}

func quickSort(_ items: inout [Int], _ low: Int, _ high: Int, choose: (Int, Int) -> Int) {
    guard low < high else { return }
    let p = partition(&items, low, high, pivotIndex: choose(low, high))
    quickSort(&items, low, p - 1, choose: choose)
    quickSort(&items, p + 1, high, choose: choose)
}

let n = 2_000
let sorted = Array(0..<n)
let mixed = (0..<n).map { ($0 * 7_919) % n }
for (name, input) in [("sorted", sorted), ("mixed", mixed)] {
    var lastPivot = input
    comparisons = 0
    quickSort(&lastPivot, 0, n - 1) { _, high in high }
    let fixed = comparisons

    var randomPivot = input
    comparisons = 0
    quickSort(&randomPivot, 0, n - 1) { low, high in dice.roll(low...high) }
    print("\(name): last-element pivot \(fixed), random pivot \(comparisons)")
}
