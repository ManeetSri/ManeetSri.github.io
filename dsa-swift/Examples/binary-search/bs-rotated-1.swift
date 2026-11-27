// Generated from src/dsa/content/lessons/binary-search/bs-rotated.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func minimumIndex(_ items: [Int]) -> Int {
    var low = 0
    var high = items.count - 1
    while low < high {
        let mid = low + (high - low) / 2
        if items[mid] > items[high] {
            low = mid + 1          // the values drop after mid: the minimum is to the right
        } else {
            high = mid             // mid...high is sorted: the minimum is mid or to its left
        }
    }
    return low
}

for items in [[40, 50, 60, 70, 10, 20, 30], [10, 20, 30, 40], [20, 10], [5]] {
    let index = minimumIndex(items)
    print(items, "minimum", items[index], "at index", index)
}
