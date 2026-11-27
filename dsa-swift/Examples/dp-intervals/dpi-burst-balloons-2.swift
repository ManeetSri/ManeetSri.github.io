// Generated from src/dsa/content/lessons/dp-intervals/dpi-burst-balloons.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bruteForce(_ balloons: [Int]) -> Int {
    var best = 0
    for i in balloons.indices {
        let left = i > 0 ? balloons[i - 1] : 1
        let right = i < balloons.count - 1 ? balloons[i + 1] : 1
        var rest = balloons
        rest.remove(at: i)
        best = max(best, left * balloons[i] * right + bruteForce(rest))
    }
    return best
}

func maxScore(_ balloons: [Int]) -> Int {
    let values = [1] + balloons + [1]
    let n = values.count
    var best = Array(repeating: Array(repeating: 0, count: n), count: n)
    if n < 3 { return 0 }
    for gap in 2..<n {
        for left in 0..<(n - gap) {
            let right = left + gap
            for last in (left + 1)..<right {
                best[left][right] = max(best[left][right], best[left][last] + best[last][right] + values[left] * values[last] * values[right])
            }
        }
    }
    return best[0][n - 1]
}

for balloons in [[4, 2, 6], [7, 1, 8, 2], [3, 0, 5, 1, 4], [9], [2, 2, 2, 2, 2, 2]] {
    print(balloons, bruteForce(balloons), maxScore(balloons))
}
