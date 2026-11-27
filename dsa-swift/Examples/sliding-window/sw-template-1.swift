// Generated from src/dsa/content/lessons/sliding-window/sw-template.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func mostFruit(_ trees: [Int]) -> Int {
    var counts: [Int: Int] = [:]
    var left = 0
    var best = 0
    for right in 0..<trees.count {
        counts[trees[right], default: 0] += 1          // 1. grow
        while counts.count > 2 {                        // invalid: three types
            let leaving = trees[left]                   // 2. shrink
            counts[leaving, default: 0] -= 1
            if counts[leaving] == 0 {
                counts[leaving] = nil
            }
            left += 1
        }
        best = max(best, right - left + 1)              // 3. record
    }
    return best
}

print(mostFruit([1, 2, 1, 3, 3, 2, 2]))
print(mostFruit([4, 4, 4]))
print(mostFruit([]))
