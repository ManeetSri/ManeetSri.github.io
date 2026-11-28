// Generated from src/dsa/content/lessons/sliding-window/sw-fixed.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func maxWindowSumBrute(_ items: [Int], _ k: Int) -> (best: Int, additions: Int) {
    var best = Int.min
    var additions = 0
    for start in 0...(items.count - k) {
        var sum = 0
        for index in start..<start + k {
            sum += items[index]
            additions += 1
        }
        best = max(best, sum)
    }
    return (best, additions)
}

let numbers = (0..<10_000).map { ($0 * 37) % 101 }
let result = maxWindowSumBrute(numbers, 1_000)
print(result.best, result.additions)
