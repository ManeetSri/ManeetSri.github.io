// Generated from src/dsa/content/lessons/dp-lis/lis-print-count.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countLongestIncreasing(_ items: [Int]) -> (length: Int, count: Int) {
    var length = Array(repeating: 1, count: items.count)
    var count = Array(repeating: 1, count: items.count)     // how many runs of the best length end at i
    for i in items.indices {
        for j in 0..<i where items[j] < items[i] {
            if length[j] + 1 > length[i] {
                length[i] = length[j] + 1                   // a longer run: start counting afresh
                count[i] = count[j]
            } else if length[j] + 1 == length[i] {
                count[i] += count[j]                        // another way to the same best length
            }
        }
    }
    let best = length.max() ?? 0
    var total = 0
    for i in items.indices where length[i] == best {
        total += count[i]
    }
    return (best, total)
}

print(countLongestIncreasing([3, 1, 4, 2, 5]))
print(countLongestIncreasing([1, 3, 5, 4, 7]))
print(countLongestIncreasing([2, 2, 2, 2, 2]))
print(countLongestIncreasing([]))
