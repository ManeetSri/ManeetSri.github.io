// Generated from src/dsa/content/lessons/binary-search/bs-classic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func binarySearch<Element: Comparable>(_ items: [Element], for target: Element) -> Int? {
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

let letters = Array("acdfhkmpt")                  // [Character], with O(1) indexing
print(binarySearch(letters, for: "k") as Any)
print(binarySearch(["ant", "bee", "cat", "dog"], for: "cat") as Any)
