// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick-pivots.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 7)
var comparisons = 0

func isLess(_ a: Int, _ b: Int) -> Bool {
    comparisons += 1
    return a < b
}

// Two-way (Lomuto) with a random pivot
func quickSortTwoWay(_ items: inout [Int], _ low: Int, _ high: Int) {
    guard low < high else { return }
    items.swapAt(dice.roll(low...high), high)
    let pivot = items[high]
    var boundary = low
    for j in low..<high where isLess(items[j], pivot) {
        items.swapAt(boundary, j)
        boundary += 1
    }
    items.swapAt(boundary, high)
    quickSortTwoWay(&items, low, boundary - 1)
    quickSortTwoWay(&items, boundary + 1, high)
}

// Three-way with a random pivot: the equal block is finished and never looked at again
func quickSortThreeWay(_ items: inout [Int], _ low: Int, _ high: Int) {
    guard low < high else { return }
    let pivot = items[dice.roll(low...high)]
    var less = low
    var scan = low
    var greater = high + 1
    while scan < greater {
        if isLess(items[scan], pivot) {
            items.swapAt(less, scan)
            less += 1
            scan += 1
        } else if isLess(pivot, items[scan]) {
            greater -= 1
            items.swapAt(scan, greater)
        } else {
            scan += 1
        }
    }
    quickSortThreeWay(&items, low, less - 1)
    quickSortThreeWay(&items, greater, high)
}

let n = 2_000
let inputs = [
    ("all equal", Array(repeating: 5, count: n)),
    ("3 distinct values", (0..<n).map { $0 % 3 }),
    ("all different", (0..<n).map { ($0 * 7_919) % n }),
]
for (name, input) in inputs {
    var a = input
    comparisons = 0
    quickSortTwoWay(&a, 0, n - 1)
    let twoWay = comparisons
    var b = input
    comparisons = 0
    quickSortThreeWay(&b, 0, n - 1)
    print("\(name): two-way \(twoWay), three-way \(comparisons), both sorted: \(a == input.sorted() && b == a)")
}
