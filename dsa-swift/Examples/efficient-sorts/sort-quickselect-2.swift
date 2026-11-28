// Generated from src/dsa/content/lessons/efficient-sorts/sort-quickselect.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Comparisons quickselect makes to find the median, against n log₂ n for sorting
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 1)
var comparisons = 0

func partition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    items.swapAt(dice.roll(low...high), high)
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

func quickselect(_ numbers: [Int], _ k: Int) -> Int {
    var items = numbers
    var low = 0
    var high = items.count - 1
    while true {
        let p = partition(&items, low, high)
        if p == k { return items[p] }
        if k < p { high = p - 1 } else { low = p + 1 }
    }
}

for n in [1_000, 10_000, 100_000] {
    let numbers = (0..<n).map { ($0 * 7_919) % n }
    comparisons = 0
    let median = quickselect(numbers, n / 2)
    var log2n = 0
    while (1 << log2n) < n { log2n += 1 }
    let tenths = comparisons * 10 / n
    print("n = \(n): median \(median), \(comparisons) comparisons (\(tenths / 10).\(tenths % 10) per element); n × ⌈log₂ n⌉ = \(n * log2n)")
}
