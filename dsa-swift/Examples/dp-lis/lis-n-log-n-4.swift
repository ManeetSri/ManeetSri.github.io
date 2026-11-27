// Generated from src/dsa/content/lessons/dp-lis/lis-n-log-n.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestRun(_ items: [Int], allowEqual: Bool) -> Int {
    var tails: [Int] = []
    for x in items {
        var low = 0
        var high = tails.count
        while low < high {
            let mid = low + (high - low) / 2
            // Strictly increasing: the first tail >= x. Non-decreasing: the first tail > x.
            let goLeft = allowEqual ? tails[mid] > x : tails[mid] >= x
            if goLeft {
                high = mid
            } else {
                low = mid + 1
            }
        }
        if low == tails.count {
            tails.append(x)
        } else {
            tails[low] = x
        }
    }
    return tails.count
}

for items in [[2, 2, 2], [1, 3, 3, 2, 3]] {
    print(items, "strict:", longestRun(items, allowEqual: false), "non-decreasing:", longestRun(items, allowEqual: true))
}
