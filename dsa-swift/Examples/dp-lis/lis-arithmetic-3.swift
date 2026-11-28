// Generated from src/dsa/content/lessons/dp-lis/lis-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestWithStep(_ items: [Int], step: Int) -> Int {
    var best: [Int: Int] = [:]
    var answer = 0
    for x in items {
        let length = best[x - step, default: 0] + 1
        best[x] = length                        // a later x is always at least as good
        answer = max(answer, length)
    }
    return answer
}

print(longestWithStep([1, 5, 7, 8, 5, 3, 4, 2, 1], step: -2))
print(longestWithStep([3, 6, 9, 4, 12, 15], step: 3))
