// Generated from src/dsa/content/lessons/dp-lis/lis-print-count.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func oneLongestIncreasingFast(_ items: [Int]) -> [Int] {
    var tails: [Int] = []                                    // indexes now, not values
    var parent = Array(repeating: -1, count: items.count)
    for (i, x) in items.enumerated() {
        var low = 0
        var high = tails.count
        while low < high {                                   // lower bound on items[tails[...]]
            let mid = low + (high - low) / 2
            if items[tails[mid]] >= x {
                high = mid
            } else {
                low = mid + 1
            }
        }
        if low > 0 {
            parent[i] = tails[low - 1]                       // x extends the run that ends there
        }
        if low == tails.count {
            tails.append(i)
        } else {
            tails[low] = i
        }
    }
    var run: [Int] = []
    var index = tails.last ?? -1
    while index != -1 {
        run.append(items[index])
        index = parent[index]
    }
    return run.reversed()
}

print(oneLongestIncreasingFast([3, 4, 5, 1, 2]))
print(oneLongestIncreasingFast([10, 9, 2, 5, 3, 7, 101, 18]))
