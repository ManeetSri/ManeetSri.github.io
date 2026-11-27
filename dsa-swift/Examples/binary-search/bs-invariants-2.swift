// Generated from src/dsa/content/lessons/binary-search/bs-invariants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func buggySearch(_ items: [Int], for target: Int) -> String {
    var low = 0
    var high = items.count - 1
    var passes = 0
    while low <= high {
        passes += 1
        if passes > 10 {
            return "stuck at low \(low), high \(high)"
        }
        let mid = low + (high - low) / 2
        if items[mid] == target {
            return "found at \(mid)"
        } else if items[mid] < target {
            low = mid + 1
        } else {
            high = mid                         // bug: should be mid - 1
        }
    }
    return "not found"
}

print(buggySearch([1, 3, 5, 7], for: 5))
print(buggySearch([1, 3, 5, 7], for: 7))
print(buggySearch([1, 3, 5, 7], for: 0))
