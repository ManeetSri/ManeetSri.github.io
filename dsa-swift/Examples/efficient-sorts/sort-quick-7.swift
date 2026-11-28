// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Recurse into the smaller side, loop on the larger: the depth stays O(log n)
var deepest = 0

func partition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    let pivot = items[high]
    var boundary = low
    for j in low..<high where items[j] < pivot {
        items.swapAt(boundary, j)
        boundary += 1
    }
    items.swapAt(boundary, high)
    return boundary
}

func quickSort(_ items: inout [Int], _ low: Int, _ high: Int, depth: Int = 1) {
    deepest = max(deepest, depth)
    var low = low
    var high = high
    while low < high {
        let p = partition(&items, low, high)
        if p - low < high - p {
            quickSort(&items, low, p - 1, depth: depth + 1)    // the smaller side: recurse
            low = p + 1                                        // the larger side: loop
        } else {
            quickSort(&items, p + 1, high, depth: depth + 1)
            high = p - 1
        }
    }
}

let n = 2_000
for (name, input) in [("mixed", (0..<n).map { ($0 * 7_919) % n }), ("sorted", Array(0..<n))] {
    var items = input
    deepest = 0
    quickSort(&items, 0, items.count - 1)
    print("\(name): recursion depth \(deepest), sorted correctly: \(items == input.sorted())")
}
