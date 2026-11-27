// Generated from src/dsa/content/lessons/dp-foundations/dp-memoisation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cheapestCrossing(_ heights: [Int]) -> Int {
    var memo = [Int?](repeating: nil, count: heights.count)
    var depth = 0
    var deepest = 0

    func cost(_ i: Int) -> Int {
        depth += 1
        defer { depth -= 1 }
        deepest = max(deepest, depth)
        if i == 0 {
            return 0
        }
        if let known = memo[i] {
            return known
        }
        var best = cost(i - 1) + abs(heights[i] - heights[i - 1])
        if i >= 2 {
            best = min(best, cost(i - 2) + abs(heights[i] - heights[i - 2]))
        }
        memo[i] = best
        return best
    }

    // Warm the memo from the smallest subproblem up, so no call recurses more than a step or two
    for i in 0..<heights.count {
        _ = cost(i)
    }
    print("deepest recursion:", deepest)
    return memo[heights.count - 1] ?? 0
}

print(cheapestCrossing((0..<200_000).map { ($0 * 7919) % 1000 }))
