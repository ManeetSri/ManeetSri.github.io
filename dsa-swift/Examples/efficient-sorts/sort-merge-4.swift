// Generated from src/dsa/content/lessons/efficient-sorts/sort-merge.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Comparisons made by top-down merge sort, on three kinds of input
var comparisons = 0

func merge(_ left: [Int], _ right: [Int]) -> [Int] {
    var merged: [Int] = []
    var i = 0
    var j = 0
    while i < left.count && j < right.count {
        comparisons += 1
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

func mergeSort(_ items: [Int]) -> [Int] {
    guard items.count > 1 else { return items }
    let mid = items.count / 2
    return merge(mergeSort(Array(items[..<mid])), mergeSort(Array(items[mid...])))
}

for n in [1_000, 10_000] {
    let ascending = Array(0..<n)
    let descending = Array(ascending.reversed())
    let mixed = (0..<n).map { ($0 * 7_919) % n }
    var line = "n = \(n):"
    for (name, input) in [("sorted", ascending), ("reversed", descending), ("mixed", mixed)] {
        comparisons = 0
        _ = mergeSort(input)
        line += " \(name) \(comparisons)"
    }
    var log2n = 0
    while (1 << log2n) < n { log2n += 1 }
    print(line + ", n × ⌈log₂ n⌉ = \(n * log2n)")
}
