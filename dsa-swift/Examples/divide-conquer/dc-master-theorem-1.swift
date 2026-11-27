// Generated from src/dsa/content/lessons/divide-conquer/dc-master-theorem.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var copied = 0
var comparisons = 0

// Binary search that recurses on a copy of the half it keeps: correct, but every call copies
func containsByCopying(_ items: [Int], _ target: Int) -> Bool {
    if items.isEmpty { return false }
    comparisons += 1
    let mid = items.count / 2
    if items[mid] == target { return true }
    let half = items[mid] < target ? Array(items[(mid + 1)...]) : Array(items[..<mid])
    copied += half.count
    return containsByCopying(half, target)
}

// Binary search on indices: nothing is copied
func containsByIndex(_ items: [Int], _ target: Int) -> Bool {
    var low = 0
    var high = items.count
    while low < high {
        comparisons += 1
        let mid = low + (high - low) / 2
        if items[mid] == target { return true }
        if items[mid] < target { low = mid + 1 } else { high = mid }
    }
    return false
}

let items = Array(0..<1_000_000)
_ = containsByCopying(items, -1)
print("copying halves: \(comparisons) comparisons, \(copied) elements copied")
comparisons = 0
_ = containsByIndex(items, -1)
print("passing indices: \(comparisons) comparisons, nothing copied")
