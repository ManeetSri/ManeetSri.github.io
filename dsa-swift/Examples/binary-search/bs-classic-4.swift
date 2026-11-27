// Generated from src/dsa/content/lessons/binary-search/bs-classic.mdx. Edit the lesson, then run
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

let jumbled = [9, 2, 7, 4, 5]
print(jumbled.contains(9))
print(binarySearch(jumbled, for: 9) as Any)
