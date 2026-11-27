// Generated from src/dsa/content/lessons/binary-search/bs-bounds.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstIndex(in items: [Int], where condition: (Int) -> Bool) -> Int {
    var low = 0
    var high = items.count
    while low < high {
        let mid = low + (high - low) / 2
        if condition(items[mid]) {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

func lowerBound(_ items: [Int], _ x: Int) -> Int { firstIndex(in: items) { $0 >= x } }
func upperBound(_ items: [Int], _ x: Int) -> Int { firstIndex(in: items) { $0 > x } }

let readings = [1, 3, 3, 3, 5, 8]
for x in [3, 4, 0, 9] {
    print("x = \(x): lower \(lowerBound(readings, x)), upper \(upperBound(readings, x))")
}
