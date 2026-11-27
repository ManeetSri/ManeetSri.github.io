// Generated from src/dsa/content/lessons/sliding-window/sw-at-most-k.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func atMost(_ values: [Int], _ k: Int) -> Int {
    guard k > 0 else { return 0 }
    var counts: [Int: Int] = [:]
    var left = 0
    var total = 0
    for right in 0..<values.count {
        counts[values[right], default: 0] += 1
        while counts.count > k {
            let leaving = values[left]
            counts[leaving, default: 0] -= 1
            if counts[leaving] == 0 {
                counts[leaving] = nil
            }
            left += 1
        }
        total += right - left + 1
    }
    return total
}

func exactly(_ values: [Int], _ k: Int) -> Int {
    atMost(values, k) - atMost(values, k - 1)
}

func exactlyBrute(_ values: [Int], _ k: Int) -> Int {
    var total = 0
    for start in values.indices {
        var seen = Set<Int>()
        for end in start..<values.count {
            seen.insert(values[end])
            if seen.count == k {
                total += 1
            }
        }
    }
    return total
}

let values = [4, 4, 7, 4, 9]
print(atMost(values, 2), atMost(values, 1), exactly(values, 2))
print(exactlyBrute(values, 2))
print(exactly([5, 5, 5], 1), exactly([1, 2, 3], 4))
