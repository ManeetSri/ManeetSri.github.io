// Generated from src/dsa/content/lessons/elementary-sorts/sort-selection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func selectionCounts(_ input: [Int]) -> (comparisons: Int, swaps: Int) {
    var items = input
    var comparisons = 0
    var swaps = 0
    guard items.count > 1 else { return (0, 0) }
    for i in 0..<(items.count - 1) {
        var smallest = i
        for j in (i + 1)..<items.count {
            comparisons += 1
            if items[j] < items[smallest] { smallest = j }
        }
        if smallest != i {
            items.swapAt(i, smallest)
            swaps += 1
        }
    }
    return (comparisons, swaps)
}

let n = 100
print("sorted:", selectionCounts(Array(0..<n)))
print("reversed:", selectionCounts(Array((0..<n).reversed())))
print("mixed:", selectionCounts((0..<n).map { ($0 * 37) % n }))
