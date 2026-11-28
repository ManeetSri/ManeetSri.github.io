// Generated from src/dsa/content/lessons/dp-foundations/dp-memoisation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cheapestCrossing(_ heights: [Int]) -> (cost: Int, calls: Int) {
    var memo = [Int?](repeating: nil, count: heights.count)   // memo[i]: the answer for stone i, once known
    var calls = 0

    func cost(_ i: Int) -> Int {
        calls += 1
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

    return (cost(heights.count - 1), calls)
}

print(cheapestCrossing([10, 30, 40, 20, 50, 10]))
print(cheapestCrossing((0..<30).map { ($0 * 37) % 50 }))
print(cheapestCrossing((0..<1000).map { ($0 * 37) % 50 }))
