// Generated from src/dsa/content/lessons/binary-search/bs-bounds.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binarySearch(_ items: [Int], for target: Int) -> Int? {
    var low = 0
    var high = items.count - 1
    while low <= high {
        let mid = low + (high - low) / 2
        if items[mid] == target {
            return mid
        } else if items[mid] < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return nil
}

let readings = [1, 3, 3, 3, 5, 8]
print(binarySearch(readings, for: 3) as Any)
