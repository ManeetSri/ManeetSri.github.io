// Generated from src/dsa/content/lessons/balanced-trees/bal-ordered-map.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Insert n values, in a scrambled order, into a sorted array. Binary search finds each place in
// O(log n) steps, but insert(_:at:) then shifts every element after that place up by one.
func lowerBound(_ items: [Int], _ value: Int, steps: inout Int) -> Int {
    var low = 0
    var high = items.count
    while low < high {
        steps += 1
        let mid = low + (high - low) / 2
        if items[mid] < value { low = mid + 1 } else { high = mid }
    }
    return low
}

for n in [1_000, 10_000, 100_000] {
    var sorted: [Int] = []
    var searchSteps = 0
    var shifts = 0
    for i in 0..<n {
        let value = (i * 7_919) % n                  // 0..<n, scrambled
        let index = lowerBound(sorted, value, steps: &searchSteps)
        shifts += sorted.count - index
        sorted.insert(value, at: index)
    }
    print("n = \(n): \(searchSteps) search steps, \(shifts) shifts")
}
