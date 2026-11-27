// Generated from src/dsa/content/lessons/elementary-sorts/sort-bubble.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bubbleCounts(_ input: [Int]) -> (comparisons: Int, swaps: Int) {
    var items = input
    var comparisons = 0
    var swaps = 0
    guard items.count > 1 else { return (0, 0) }
    for pass in 0..<(items.count - 1) {
        var swapped = false
        for j in 0..<(items.count - 1 - pass) {
            comparisons += 1
            if items[j] > items[j + 1] {
                items.swapAt(j, j + 1)
                swaps += 1
                swapped = true
            }
        }
        if !swapped { break }
    }
    return (comparisons, swaps)
}

let n = 100
print("sorted:", bubbleCounts(Array(0..<n)))
print("reversed:", bubbleCounts(Array((0..<n).reversed())))
print("big value first:", bubbleCounts([n] + Array(1..<n)))
print("small value last:", bubbleCounts(Array(1..<n) + [0]))
