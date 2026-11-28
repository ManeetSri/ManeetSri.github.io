// Generated from src/dsa/content/lessons/dp-intervals/dpi-burst-balloons.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bestPopping(_ balloons: [Int]) -> (score: Int, order: [Int]) {
    let values = [1] + balloons + [1]                    // walls worth 1 at both ends
    let n = values.count
    var best = Array(repeating: Array(repeating: 0, count: n), count: n)
    var lastPopped = Array(repeating: Array(repeating: -1, count: n), count: n)
    if n >= 3 {
        for gap in 2..<n {                               // narrow ranges first
            for left in 0..<(n - gap) {
                let right = left + gap
                for last in (left + 1)..<right {         // the last balloon popped between the walls
                    let total = best[left][last] + best[last][right] + values[left] * values[last] * values[right]
                    if lastPopped[left][right] == -1 || total > best[left][right] {
                        best[left][right] = total
                        lastPopped[left][right] = last
                    }
                }
            }
        }
    }

    // Pop everything left of the last balloon, then everything right of it, then the balloon itself
    func order(_ left: Int, _ right: Int) -> [Int] {
        guard right - left >= 2 else { return [] }
        let last = lastPopped[left][right]
        return order(left, last) + order(last, right) + [values[last]]
    }

    return (best[0][n - 1], order(0, n - 1))
}

print(bestPopping([4, 2, 6]))
print(bestPopping([7, 1, 8, 2]))
print(bestPopping([]))
