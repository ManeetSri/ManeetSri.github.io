// Generated from src/dsa/content/lessons/advanced-graphs/ag-hamiltonian.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Held–Karp: best[mask][last] = shortest path from city 0 through exactly the cities in mask, ending at last
func shortestTour(_ distance: [[Int]]) -> (length: Int, tour: [Int]) {
    let n = distance.count
    let full = 1 << n
    let unreached = Int.max / 2
    var best = [[Int]](repeating: [Int](repeating: unreached, count: n), count: full)
    var previous = [[Int]](repeating: [Int](repeating: -1, count: n), count: full)
    best[1][0] = 0                                  // only city 0 visited, standing at city 0

    for mask in 1..<full where mask & 1 == 1 {      // every path starts at city 0
        for last in 0..<n where mask & (1 << last) != 0 && best[mask][last] < unreached {
            for next in 0..<n where mask & (1 << next) == 0 {
                let grown = mask | (1 << next)
                let candidate = best[mask][last] + distance[last][next]
                if candidate < best[grown][next] {
                    best[grown][next] = candidate
                    previous[grown][next] = last    // remember how we got here
                }
            }
        }
    }

    // Close the loop back to city 0 from the best last city
    var length = unreached
    var last = 0
    for city in 1..<n where best[full - 1][city] + distance[city][0] < length {
        length = best[full - 1][city] + distance[city][0]
        last = city
    }
    // Walk the `previous` links back to rebuild the tour
    var tour: [Int] = []
    var mask = full - 1
    while last != -1 {
        tour.append(last)
        let before = previous[mask][last]
        mask &= ~(1 << last)
        last = before
    }
    return (length, tour.reversed() + [0])
}

let distance = [
    [0, 12, 10, 19, 8],
    [12, 0, 3, 7, 2],
    [10, 3, 0, 6, 20],
    [19, 7, 6, 0, 4],
    [8, 2, 20, 4, 0],
]
let small = shortestTour(distance)
print("5 cities:", small.length, "via", small.tour)

// 15 cities with distances from a fixed formula: 2^15 · 15 · 15 ≈ 7.4 million steps
let n = 15
let big = (0..<n).map { i in (0..<n).map { j in i == j ? 0 : (i * 37 + j * 91) % 50 + 1 } }
let answer = shortestTour(big)
print("15 cities:", answer.length, "via", answer.tour)
print("states in the table:", (1 << n) * n)
