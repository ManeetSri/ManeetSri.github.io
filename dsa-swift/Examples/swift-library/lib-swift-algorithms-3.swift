// Generated from src/dsa/content/lessons/swift-library/lib-swift-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// uniqued(): keep the first of each value, in order
var seen = Set<String>()
let visits = ["home", "search", "home", "cart", "search", "pay"]
let firstVisits = visits.filter { seen.insert($0).inserted }
print(firstVisits)

// uniqued(on:): keep the first element for each key
var seenLengths = Set<Int>()
print(visits.filter { seenLengths.insert($0.count).inserted })

// minAndMax(): both extremes in one pass
func minAndMax(_ values: [Int]) -> (min: Int, max: Int)? {
    guard var low = values.first else { return nil }
    var high = low
    for value in values.dropFirst() {
        low = min(low, value)
        high = max(high, value)
    }
    return (low, high)
}
if let range = minAndMax([7, 1, 6, 2, 8, 3, 9]) {
    print(range.min, range.max)
}
print(minAndMax([]) == nil)
