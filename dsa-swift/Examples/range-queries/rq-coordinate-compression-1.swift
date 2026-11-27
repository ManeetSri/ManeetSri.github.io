// Generated from src/dsa/content/lessons/range-queries/rq-coordinate-compression.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Coordinate compression: replace each value by its rank among the distinct values
let ids = [1_000_000_000, 5, 300, 5, 42, 300, -7]

let distinct = Array(Set(ids)).sorted()          // sort and dedupe
print("distinct:", distinct)

/// The index of the first element ≥ target in a sorted array (lower bound)
func lowerBound(_ sorted: [Int], _ target: Int) -> Int {
    var low = 0
    var high = sorted.count
    while low < high {
        let mid = low + (high - low) / 2
        if sorted[mid] < target { low = mid + 1 } else { high = mid }
    }
    return low
}

let byBinarySearch = ids.map { lowerBound(distinct, $0) }
print("ranks (binary search):", byBinarySearch)

var rankOf: [Int: Int] = [:]
for (rank, value) in distinct.enumerated() {
    rankOf[value] = rank
}
let byDictionary = ids.map { rankOf[$0]! }
print("ranks (dictionary):   ", byDictionary)
print("back again:", byDictionary.map { distinct[$0] })
