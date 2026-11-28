// Generated from src/dsa/content/lessons/dp-grids/dpg-dungeon.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// With the starting health fixed, forwards works: more health is always at least as good
func survives(_ dungeon: [[Int]], startingWith health: Int) -> Bool {
    let cols = dungeon[0].count
    // best[c]: the most health you can have after cell (r, c), or 0 if you can't get there alive
    var best = Array(repeating: 0, count: cols)
    for r in dungeon.indices {
        for c in 0..<cols {
            let arriving = r == 0 && c == 0 ? health : max(r > 0 ? best[c] : 0, c > 0 ? best[c - 1] : 0)
            let after = arriving + dungeon[r][c]
            best[c] = arriving > 0 && after > 0 ? after : 0
        }
    }
    return best[cols - 1] > 0
}

func minimumStartHealth(_ dungeon: [[Int]]) -> Int {
    var low = 1
    var high = 1 + dungeon.joined().filter { $0 < 0 }.reduce(0) { $0 - $1 }   // enough for every trap
    while low < high {
        let mid = low + (high - low) / 2
        if survives(dungeon, startingWith: mid) {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

let dungeon = [[0, -8, 20], [-1, -1, -1], [-1, -1, 0]]
print((1...5).map { survives(dungeon, startingWith: $0) })
print(minimumStartHealth(dungeon))
print(minimumStartHealth([[-4, 3], [-2, -6]]))
