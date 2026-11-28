// Reference solution: the shortest-path counter, with its Swift gotchas fixed. The algorithm is the
// same BFS: a cell's count is the sum of the counts of its neighbours one step closer to S. The fixes:
// read the rows once as UTF-8 bytes (String has no O(1) Int subscript), walk the queue with a head
// index (removeFirst() shifts the whole array), and reduce modulo 1,000,000,007 after every addition
// (the true counts overflow Int long before the end). O(rows × columns) time and space.

public enum ShortestPathCounterFix {
    public static func count(_ rows: [String]) -> Int {
        let modulus = 1_000_000_007
        let height = rows.count
        guard let width = rows.first?.utf8.count, width > 0 else { return 0 }
        let cells = rows.flatMap { Array($0.utf8) }          // cell r * width + c, one byte each
        guard let start = cells.firstIndex(of: UInt8(ascii: "S")),
              let goal = cells.firstIndex(of: UInt8(ascii: "G")) else { return 0 }

        var distance = [Int](repeating: -1, count: cells.count)
        var ways = [Int](repeating: 0, count: cells.count)
        distance[start] = 0
        ways[start] = 1
        var queue = [start]
        var head = 0

        /// Reaching `next` from `cell`: record its distance the first time, and add the ways from every
        /// cell one step closer
        func visit(_ next: Int, from cell: Int) {
            guard cells[next] != UInt8(ascii: "#") else { return }
            if distance[next] == -1 {
                distance[next] = distance[cell] + 1
                queue.append(next)
            }
            if distance[next] == distance[cell] + 1 {
                ways[next] = (ways[next] + ways[cell]) % modulus
            }
        }

        while head < queue.count {
            let cell = queue[head]
            head += 1                                        // O(1), where removeFirst() would be O(n)
            if cell == goal { break }                        // every path into the goal is counted
            let r = cell / width, c = cell % width
            if r > 0 { visit(cell - width, from: cell) }
            if r + 1 < height { visit(cell + width, from: cell) }
            if c > 0 { visit(cell - 1, from: cell) }
            if c + 1 < width { visit(cell + 1, from: cell) }
        }
        return ways[goal]
    }
}
