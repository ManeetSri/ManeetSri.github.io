// Generated from src/dsa/content/lessons/shortest-paths/sp-zero-one-bfs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A deque that is popped only from the front: amortised O(1) for all three operations
struct Deque<Element> {
    private var front: [Element] = []         // stored reversed, so its last element is first in line
    private var back: [Element] = []
    var isEmpty: Bool { front.isEmpty && back.isEmpty }

    mutating func pushFront(_ element: Element) { front.append(element) }
    mutating func pushBack(_ element: Element) { back.append(element) }
    mutating func popFront() -> Element? {
        if front.isEmpty {
            front = back.reversed()
            back.removeAll()
        }
        return front.popLast()
    }
}

/// Fewest signposts to repaint so that following them leads from the top-left to the bottom-right
func fewestRepaints(_ rows: [String]) -> Int {
    let grid = rows.map { Array($0) }
    let height = grid.count, width = grid[0].count
    let moves: [(sign: Character, dr: Int, dc: Int)] = [(">", 0, 1), ("<", 0, -1), ("v", 1, 0), ("^", -1, 0)]
    var cost = Array(repeating: Array(repeating: Int.max, count: width), count: height)
    cost[0][0] = 0
    var deque = Deque<(row: Int, col: Int, cost: Int)>()
    deque.pushBack((0, 0, 0))
    while let (row, col, c) = deque.popFront() {
        if c > cost[row][col] { continue }                   // stale
        for move in moves {
            let r = row + move.dr, k = col + move.dc
            guard r >= 0, r < height, k >= 0, k < width else { continue }
            let step = grid[row][col] == move.sign ? 0 : 1   // follow the sign for free
            if c + step < cost[r][k] {
                cost[r][k] = c + step
                if step == 0 { deque.pushFront((r, k, c)) } else { deque.pushBack((r, k, c + 1)) }
            }
        }
    }
    return cost[height - 1][width - 1]
}

print(fewestRepaints([">>v", "v<<", ">>>"]))
print(fewestRepaints([">>v", "^<<", ">>>"]))
print(fewestRepaints(["<<", "<<"]))
