// Generated from src/dsa/content/lessons/dp-intervals/dpi-cut-stick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func cheapestCutting(length: Int, marks: [Int]) -> (cost: Int, order: [Int]) {
    let points = [0] + marks.sorted() + [length]        // sort, then add both ends
    let m = points.count
    var best = Array(repeating: Array(repeating: 0, count: m), count: m)
    var firstCut = Array(repeating: Array(repeating: -1, count: m), count: m)
    if m >= 3 {
        for gap in 2..<m {                              // shorter pieces first
            for left in 0..<(m - gap) {
                let right = left + gap
                best[left][right] = Int.max
                for k in (left + 1)..<right where best[left][k] + best[k][right] < best[left][right] {
                    best[left][right] = best[left][k] + best[k][right]
                    firstCut[left][right] = k
                }
                best[left][right] += points[right] - points[left]   // the first cut's cost, added once
            }
        }
    }

    // The first cut of a piece, then everything on its left piece, then its right piece
    func order(_ left: Int, _ right: Int) -> [Int] {
        guard right - left >= 2 else { return [] }
        let k = firstCut[left][right]
        return [points[k]] + order(left, k) + order(k, right)
    }

    return (best[0][m - 1], order(0, m - 1))
}

print(cheapestCutting(length: 10, marks: [7, 2, 4]))
print(cheapestCutting(length: 10, marks: [4, 5, 6]))
print(cheapestCutting(length: 9, marks: [5, 1, 6, 3]))
print(cheapestCutting(length: 5, marks: []))
