// Generated from src/dsa/content/lessons/heaps/heap-array-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func height(ofHeapWith count: Int) -> Int {
    var steps = 0
    var index = count - 1                    // the last node
    while index > 0 {
        index = (index - 1) / 2              // up to its parent
        steps += 1
    }
    return steps
}

for count in [1, 2, 3, 7, 8, 1_000, 1_000_000] {
    print("\(count) values: height \(height(ofHeapWith: count))")
}
