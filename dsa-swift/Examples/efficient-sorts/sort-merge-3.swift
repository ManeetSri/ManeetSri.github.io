// Generated from src/dsa/content/lessons/efficient-sorts/sort-merge.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func merge(_ left: [Int], _ right: [Int]) -> [Int] {
    var merged: [Int] = []
    var i = 0
    var j = 0
    while i < left.count && j < right.count {
        if left[i] <= right[j] {
            merged.append(left[i])
            i += 1
        } else {
            merged.append(right[j])
            j += 1
        }
    }
    merged += left[i...]
    merged += right[j...]
    return merged
}

func mergeSort(_ items: [Int], depth: Int = 0) -> [Int] {
    let indent = String(repeating: "  ", count: depth)
    guard items.count > 1 else {
        return items                          // 0 or 1 elements: already sorted
    }
    let mid = items.count / 2
    let left = mergeSort(Array(items[..<mid]), depth: depth + 1)
    let right = mergeSort(Array(items[mid...]), depth: depth + 1)
    let merged = merge(left, right)
    print("\(indent)\(left) + \(right) → \(merged)")
    return merged
}

print(mergeSort([38, 27, 43, 3, 9, 82, 10]))
