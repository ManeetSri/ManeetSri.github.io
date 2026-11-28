// Generated from src/dsa/content/lessons/dp-lis/lis-n-log-n.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

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

var tails: [Int] = []
for x in [3, 4, 5, 1, 2] {
    let index = lowerBound(tails, x)
    if index == tails.count {
        tails.append(x)
    } else {
        tails[index] = x
    }
    print("after \(x):", tails)
}
