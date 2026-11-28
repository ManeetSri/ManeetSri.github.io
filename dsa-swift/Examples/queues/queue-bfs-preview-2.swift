// Generated from src/dsa/content/lessons/queues/queue-bfs-preview.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The same search on an open 3 × 3 grid, taking cells from the front (a queue) or the back (a stack)
func firstFoundDistances(useQueue: Bool) -> [[Int]] {
    let size = 3
    var distance = Array(repeating: Array(repeating: -1, count: size), count: size)
    var pending: [(Int, Int)] = [(0, 0)]
    var head = 0
    distance[0][0] = 0
    while head < pending.count {
        let (row, column) = useQueue ? pending[head] : pending.removeLast()
        if useQueue { head += 1 }
        for (dr, dc) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
            let r = row + dr
            let c = column + dc
            guard r >= 0, r < size, c >= 0, c < size, distance[r][c] == -1 else { continue }
            distance[r][c] = distance[row][column] + 1
            pending.append((r, c))
        }
    }
    return distance
}

print("queue:", firstFoundDistances(useQueue: true))
print("stack:", firstFoundDistances(useQueue: false))
