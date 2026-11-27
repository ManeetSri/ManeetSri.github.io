// Generated from src/dsa/content/lessons/patterns/pat-templates-linear.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Read/write pointers: keep each value at most twice, in place, in a sorted array
func keepAtMostTwo(_ items: inout [Int]) -> Int {
    var write = 0
    for read in items.indices {
        // Keep items[read] unless the last two kept values already equal it
        if write < 2 || items[read] != items[write - 2] {
            items[write] = items[read]
            write += 1
        }
    }
    return write                                  // items[0..<write] is the result
}

var scores = [1, 1, 1, 2, 2, 3, 3, 3, 3, 4]
let kept = keepAtMostTwo(&scores)
print(kept, Array(scores[0..<kept]))
