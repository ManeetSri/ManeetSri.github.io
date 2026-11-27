// Generated from src/dsa/content/lessons/binary-search/bs-classic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binarySearch(_ items: [Int], for target: Int, low: Int, high: Int) -> Int? {
    guard low <= high else {
        return nil                                   // an empty range: not here
    }
    let mid = low + (high - low) / 2
    if items[mid] == target {
        return mid
    } else if items[mid] < target {
        return binarySearch(items, for: target, low: mid + 1, high: high)
    } else {
        return binarySearch(items, for: target, low: low, high: mid - 1)
    }
}

let sorted = [3, 8, 12, 17, 21, 26, 30, 34, 41, 45, 52]
print(binarySearch(sorted, for: 45, low: 0, high: sorted.count - 1) as Any)
print(binarySearch(sorted, for: 4, low: 0, high: sorted.count - 1) as Any)
