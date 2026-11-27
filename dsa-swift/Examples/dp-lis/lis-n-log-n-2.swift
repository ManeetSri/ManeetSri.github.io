// Generated from src/dsa/content/lessons/dp-lis/lis-n-log-n.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// The first index whose value is at least x, in a sorted array (the lower bound)
func lowerBound(_ sorted: [Int], _ x: Int) -> Int {
    var low = 0
    var high = sorted.count
    while low < high {
        let mid = low + (high - low) / 2
        if sorted[mid] >= x {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

func lengthOfLIS(_ items: [Int]) -> Int {
    var tails: [Int] = []          // tails[k]: the smallest end of any increasing run of length k + 1
    for x in items {
        let index = lowerBound(tails, x)
        if index == tails.count {
            tails.append(x)        // x beats every tail: the longest run grows by one
        } else {
            tails[index] = x       // a run of length index + 1 can now end lower
        }
    }
    return tails.count
}

print(lengthOfLIS([10, 9, 2, 5, 3, 7, 101, 18]))
print(lengthOfLIS([0, 8, 4, 12, 2, 10, 6, 14, 1, 9, 5, 13, 3, 11, 7, 15]))
print(lengthOfLIS([7, 7, 7]))
print(lengthOfLIS([]))
