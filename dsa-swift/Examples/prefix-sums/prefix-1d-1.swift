// Generated from src/dsa/content/lessons/prefix-sums/prefix-1d.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func slowRangeSum(_ items: [Int], from start: Int, through end: Int) -> Int {
    var total = 0
    for index in start...end {
        total += items[index]
    }
    return total
}

let items = [3, 1, 4, 1, 5, 9, 2]
print(slowRangeSum(items, from: 2, through: 5))
print(slowRangeSum(items, from: 0, through: 6))
