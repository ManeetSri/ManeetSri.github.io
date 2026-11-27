// Generated from src/dsa/content/lessons/elementary-sorts/sort-insertion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binaryInsertionSort(_ items: inout [Int]) -> (comparisons: Int, moves: Int) {
    var comparisons = 0
    var moves = 0
    guard items.count > 1 else { return (0, 0) }
    for i in 1..<items.count {
        let key = items[i]
        // The first position in items[0..<i] holding a value bigger than the key
        var low = 0
        var high = i
        while low < high {
            let mid = (low + high) / 2
            comparisons += 1
            if items[mid] > key { high = mid } else { low = mid + 1 }
        }
        // Everything from there to i still has to shift one place right
        var gap = i
        while gap > low {
            items[gap] = items[gap - 1]
            gap -= 1
            moves += 1
        }
        items[low] = key
    }
    return (comparisons, moves)
}

var reversed = Array((0..<1_000).reversed())
print(binaryInsertionSort(&reversed))
print(reversed[..<5])
