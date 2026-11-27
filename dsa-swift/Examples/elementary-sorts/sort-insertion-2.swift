// Generated from src/dsa/content/lessons/elementary-sorts/sort-insertion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func insertionCounts(_ input: [Int]) -> (comparisons: Int, shifts: Int) {
    var items = input
    var comparisons = 0
    var shifts = 0
    guard items.count > 1 else { return (0, 0) }
    for i in 1..<items.count {
        let key = items[i]
        var gap = i
        while gap > 0 {
            comparisons += 1
            guard items[gap - 1] > key else { break }
            items[gap] = items[gap - 1]
            shifts += 1
            gap -= 1
        }
        items[gap] = key
    }
    return (comparisons, shifts)
}

let n = 1_000
var nearly = Array(0..<n)
for i in stride(from: 0, to: n - 1, by: 10) {
    nearly.swapAt(i, i + 1)                   // 100 neighbouring pairs swapped
}
print("sorted:", insertionCounts(Array(0..<n)))
print("nearly sorted:", insertionCounts(nearly))
print("mixed:", insertionCounts((0..<n).map { ($0 * 7_919) % n }))
print("reversed:", insertionCounts(Array((0..<n).reversed())))
