// Generated from src/dsa/content/lessons/binary-search/bs-rotated.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minimumIndex(_ items: [Int]) -> Int {
    var low = 0
    var high = items.count - 1
    while low < high {
        let mid = low + (high - low) / 2
        if items[mid] > items[high] { low = mid + 1 } else { high = mid }
    }
    return low
}

func search(_ items: [Int], for target: Int) -> Int? {
    guard !items.isEmpty else { return nil }
    let shift = minimumIndex(items)                // where sorted order begins
    var low = 0
    var high = items.count - 1                     // positions in sorted order
    while low <= high {
        let mid = low + (high - low) / 2
        let index = (shift + mid) % items.count    // sorted position → real index
        if items[index] == target {
            return index
        } else if items[index] < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return nil
}

let rotated = [40, 50, 60, 70, 10, 20, 30]
print(search(rotated, for: 20) as Any, search(rotated, for: 70) as Any, search(rotated, for: 55) as Any)
