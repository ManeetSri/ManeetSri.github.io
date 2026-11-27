// Generated from src/dsa/content/lessons/dp-lis/lis-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countArithmeticSubsequences(_ items: [Int]) -> Int {
    var ending = Array(repeating: [Int: Int](), count: items.count)
    var total = 0
    for i in items.indices {
        for j in 0..<i {
            let step = items[i] - items[j]
            let before = ending[j][step, default: 0]   // runs of length 2 or more ending at j
            total += before                            // each grows to length 3 or more
            ending[i][step, default: 0] += before + 1  // plus the new pair (j, i)
        }
    }
    return total
}

print(countArithmeticSubsequences([2, 4, 6, 8, 10]))
print(countArithmeticSubsequences([7, 7, 7, 7, 7]))
