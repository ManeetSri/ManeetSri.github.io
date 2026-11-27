// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Quick sort with a fixed pivot (the last element): comparisons and recursion depth
var comparisons = 0
var deepest = 0

func partition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
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

func quickSort(_ items: inout [Int], _ low: Int, _ high: Int, depth: Int) {
    deepest = max(deepest, depth)
    guard low < high else { return }
    let p = partition(&items, low, high)
    quickSort(&items, low, p - 1, depth: depth + 1)
    quickSort(&items, p + 1, high, depth: depth + 1)
}

let n = 2_000
let inputs = [
    ("mixed", (0..<n).map { ($0 * 7_919) % n }),
    ("sorted", Array(0..<n)),
    ("reversed", Array((0..<n).reversed())),
]
for (name, input) in inputs {
    var items = input
    comparisons = 0
    deepest = 0
    quickSort(&items, 0, items.count - 1, depth: 1)
    print("\(name): \(comparisons) comparisons, recursion depth \(deepest)")
}
