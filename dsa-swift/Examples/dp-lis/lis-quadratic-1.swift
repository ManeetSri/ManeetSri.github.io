// Generated from src/dsa/content/lessons/dp-lis/lis-quadratic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestIncreasing(_ items: [Int]) -> Int {
    var length = Array(repeating: 1, count: items.count)   // each element alone
    for i in items.indices {
        for j in 0..<i where items[j] < items[i] {
            length[i] = max(length[i], length[j] + 1)       // extend the best run ending at j
        }
    }
    print("length:", length)
    return length.max() ?? 0                                // the best run can end anywhere
}

print(longestIncreasing([10, 9, 2, 5, 3, 7, 101, 18]))
print(longestIncreasing([1, 2, 3, 0]))
print(longestIncreasing([]))
