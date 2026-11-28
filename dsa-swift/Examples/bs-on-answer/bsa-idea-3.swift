// Generated from src/dsa/content/lessons/bs-on-answer/bsa-idea.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstTrue(in range: Range<Int>, where feasible: (Int) -> Bool) -> Int {
    var low = range.lowerBound
    var high = range.upperBound
    while low < high {
        let mid = low + (high - low) / 2
        if feasible(mid) { high = mid } else { low = mid + 1 }
    }
    return low
}

func lowerBound(_ items: [Int], _ target: Int) -> Int {
    firstTrue(in: 0..<items.count) { items[$0] >= target }
}

let items = [2, 4, 4, 7, 9]
print(lowerBound(items, 4), lowerBound(items, 8), lowerBound(items, 10))
