// Generated from src/dsa/content/lessons/sliding-window/sw-at-most-k.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countAtMost(_ values: [Int], _ k: Int) -> Int {
    var counts: [Int: Int] = [:]
    var left = 0
    var total = 0
    for right in 0..<values.count {
        counts[values[right], default: 0] += 1
        while counts.count > k {
            let leaving = values[left]
            counts[leaving, default: 0] -= 1
            if counts[leaving] == 0 {
                counts[leaving] = nil          // so counts.count is the number of distinct values
            }
            left += 1
        }
        print("right \(right): starts \(left)...\(right) work, adding \(right - left + 1)")
        total += right - left + 1
    }
    return total
}

print(countAtMost([1, 2, 1, 3], 2))
