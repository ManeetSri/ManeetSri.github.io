// Generated from src/dsa/content/lessons/graph-traversals/gt-multi-source.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// 0 is an empty slot, 1 a fresh orange, 2 a rotten one. Each minute, rot spreads up, down, left and right.
let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

func minutesUntilAllRotten(_ crate: [[Int]]) -> Int {
    var crate = crate
    var queue: [(Int, Int)] = []
    var fresh = 0
    for row in crate.indices {
        for column in crate[row].indices {
            if crate[row][column] == 2 {
                queue.append((row, column))             // every rotten orange is a source
            } else if crate[row][column] == 1 {
                fresh += 1
            }
        }
    }
    var head = 0
    var minutes = 0
    while head < queue.count && fresh > 0 {
        let levelEnd = queue.count                      // the oranges that rotted last minute
        while head < levelEnd {
            let (row, column) = queue[head]
            head += 1
            for (dr, dc) in directions {
                let r = row + dr
                let c = column + dc
                guard r >= 0, r < crate.count, c >= 0, c < crate[r].count, crate[r][c] == 1 else { continue }
                crate[r][c] = 2                         // rots now: marked as it's enqueued
                fresh -= 1
                queue.append((r, c))
            }
        }
        minutes += 1
    }
    return fresh == 0 ? minutes : -1
}

print(minutesUntilAllRotten([[2, 1, 1, 0], [0, 1, 1, 1], [0, 0, 1, 2]]))
print(minutesUntilAllRotten([[1, 1, 1, 1, 1, 1, 1], [2, 0, 0, 0, 0, 0, 2]]))
print(minutesUntilAllRotten([[2, 1, 0, 1]]))
print(minutesUntilAllRotten([[0, 2], [2, 0]]))
