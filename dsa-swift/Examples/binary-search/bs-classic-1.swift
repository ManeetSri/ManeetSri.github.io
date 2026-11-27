// Generated from src/dsa/content/lessons/binary-search/bs-classic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binarySearch(_ items: [Int], for target: Int) -> Int? {
    var low = 0
    var high = items.count - 1
    while low <= high {
        let mid = low + (high - low) / 2
        print("low \(low), high \(high), mid \(mid): items[mid] = \(items[mid])")
        if items[mid] == target {
            return mid
        } else if items[mid] < target {
            low = mid + 1                  // mid and everything left of it are too small
        } else {
            high = mid - 1                 // mid and everything right of it are too big
        }
    }
    return nil
}

let sorted = [3, 8, 12, 17, 21, 26, 30, 34, 41, 45, 52]
print(binarySearch(sorted, for: 34) as Any)
print(binarySearch(sorted, for: 20) as Any)
