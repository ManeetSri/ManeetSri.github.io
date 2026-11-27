// Generated from src/dsa/content/lessons/binary-search/bs-other-searches.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func interpolationSearch(_ items: [Int], for target: Int) -> (index: Int?, probes: Int) {
    var low = 0
    var high = items.count - 1
    var probes = 0
    while low <= high && target >= items[low] && target <= items[high] {
        probes += 1
        if items[high] == items[low] {                       // avoid dividing by zero
            return (items[low] == target ? low : nil, probes)
        }
        let position = low + (target - items[low]) * (high - low) / (items[high] - items[low])
        if items[position] == target {
            return (position, probes)
        } else if items[position] < target {
            low = position + 1
        } else {
            high = position - 1
        }
    }
    return (nil, probes)
}

let n = 100_000
let even = (0..<n).map { $0 * 10 + ($0 * 7_919) % 10 }       // evenly spread, slightly jittered
let lopsided = Array(0..<(n - 1)) + [1_000_000_000_000]       // one huge value at the end

print("even:", interpolationSearch(even, for: even[73_210]))
print("lopsided:", interpolationSearch(lopsided, for: 99_990))
