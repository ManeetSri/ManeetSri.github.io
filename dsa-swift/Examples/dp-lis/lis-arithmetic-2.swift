// Generated from src/dsa/content/lessons/dp-lis/lis-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestArithmetic(_ items: [Int]) -> Int {
    guard items.count > 2 else { return items.count }
    var ending = Array(repeating: [Int: Int](), count: items.count)   // ending[i][d]: run length
    var best = 2
    for i in items.indices {
        for j in 0..<i {
            let step = items[i] - items[j]
            let length = ending[j][step, default: 1] + 1     // j alone counts as a run of 1
            ending[i][step] = max(ending[i][step, default: 0], length)
            best = max(best, length)
        }
    }
    return best
}

print(longestArithmetic([1, 7, 10, 13, 14, 19]))
print(longestArithmetic([9, 4, 7, 2, 10]))
print(longestArithmetic([5, 5, 5, 5]))
