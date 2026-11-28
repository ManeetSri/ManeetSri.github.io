// Generated from src/dsa/content/lessons/recursion/rec-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binarySearch(_ items: [Int], for target: Int) -> Int? {
    func search(_ low: Int, _ high: Int) -> Int? {
        if low > high {
            return nil                      // empty range: not here
        }
        let mid = low + (high - low) / 2
        print("searching \(low)...\(high), mid \(mid)")
        if items[mid] == target {
            return mid
        } else if items[mid] < target {
            return search(mid + 1, high)
        } else {
            return search(low, mid - 1)
        }
    }
    return search(0, items.count - 1)
}

let sorted = [2, 5, 8, 12, 16, 23, 38, 56, 72, 91]
print(binarySearch(sorted, for: 23) ?? -1)
print(binarySearch(sorted, for: 7) ?? -1)
