// Reference solution: Rumour spread. Multi-source BFS: everyone who knows at the start goes into a
// head-index queue together, and the queue is processed one ring (one minute) at a time. Each person
// is enqueued once, when they first hear, so it's O(rows × columns) time and space.

public enum RumourSpread {
    public static func minutesUntilEveryoneKnows(_ seating: [String]) -> Int {
        var desks = seating.map { Array($0) }
        var queue: [(row: Int, column: Int)] = []
        var unaware = 0
        for row in desks.indices {
            for column in desks[row].indices {
                if desks[row][column] == "K" {
                    queue.append((row, column))
                } else if desks[row][column] == "U" {
                    unaware += 1
                }
            }
        }

        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        var head = 0
        var minutes = 0
        while head < queue.count && unaware > 0 {
            let ringEnd = queue.count                // everyone who heard by the end of this minute
            while head < ringEnd {
                let (row, column) = queue[head]
                head += 1
                for (dr, dc) in directions {
                    let r = row + dr
                    let c = column + dc
                    guard r >= 0, r < desks.count, c >= 0, c < desks[r].count else { continue }
                    guard desks[r][c] == "U" else { continue }
                    desks[r][c] = "K"                // mark as they hear: never enqueued twice
                    unaware -= 1
                    queue.append((r, c))
                }
            }
            minutes += 1
        }
        return unaware == 0 ? minutes : -1
    }
}
