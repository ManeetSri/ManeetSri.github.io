// Generated from src/dsa/content/lessons/binary-search/bs-rotated.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func search(_ items: [Int], for target: Int) -> Int? {
    var low = 0
    var high = items.count - 1
    while low <= high {
        let mid = low + (high - low) / 2
        if items[mid] == target {
            return mid
        }
        if items[low] <= items[mid] {
            print("  [\(low), \(high)], mid \(mid): left half \(items[low])...\(items[mid]) is sorted")
            if items[low] <= target && target < items[mid] {
                high = mid - 1
            } else {
                low = mid + 1
            }
        } else {
            print("  [\(low), \(high)], mid \(mid): right half \(items[mid])...\(items[high]) is sorted")
            if items[mid] < target && target <= items[high] {
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
    }
    return nil
}

let rotated = [40, 50, 60, 70, 10, 20, 30]
print(search(rotated, for: 20) as Any)
print(search(rotated, for: 55) as Any)
