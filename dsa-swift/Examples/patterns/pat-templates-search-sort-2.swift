// Generated from src/dsa/content/lessons/patterns/pat-templates-search-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Binary search on any monotonic condition over indexes: false, false, ..., true, true
func firstTrue(_ count: Int, _ condition: (Int) -> Bool) -> Int {
    var low = 0
    var high = count                              // count means "never true"
    while low < high {
        let mid = low + (high - low) / 2
        if condition(mid) { high = mid } else { low = mid + 1 }
    }
    return low
}

// The smallest value in a sorted array that was rotated: the first index whose value is at most the last
let rotated = [30, 40, 50, 5, 10, 20]
let smallest = firstTrue(rotated.count) { rotated[$0] <= rotated[rotated.count - 1] }
print("minimum \(rotated[smallest]) at index \(smallest)")

// The first build that fails its tests (builds 0..<8, failing from build 5 on)
let firstBad = firstTrue(8) { build in build >= 5 }
print("first bad build:", firstBad)
