// Problem: Many short routes on one grid (M68 · ContiguousArray, reserveCapacity and buffer pointers)

public enum RepeatedGridRoutes {
    /// Answers many shortest-route queries on one grid with breadth-first search, reusing the same buffers
    /// for every query. Instead of clearing a visited array (O(cells) per query), each query gets a new
    /// stamp number: a cell counts as visited only if its stamp equals the current one. The queue is a
    /// preallocated array with head and tail indices, reset in O(1). The search stops as soon as it
    /// reaches the target.
    ///
    /// Setup is O(rows × columns). Each query costs O(cells it explores), however big the grid is.
    public struct Router {
        private let rows: Int
        private let columns: Int
        private let open: [Bool]
        private var stamp: [Int]
        private var distanceTo: [Int32]
        private var queue: [Int32]
        private var currentStamp = 0

        public init(grid: [String]) {
            rows = grid.count
            columns = grid.first?.utf8.count ?? 0
            var open: [Bool] = []
            open.reserveCapacity(rows * columns)
            for line in grid {
                for byte in line.utf8 {
                    open.append(byte != UInt8(ascii: "#"))
                }
            }
            self.open = open
            stamp = Array(repeating: 0, count: rows * columns)
            distanceTo = Array(repeating: 0, count: rows * columns)
            queue = Array(repeating: 0, count: rows * columns)
        }

        public mutating func distance(fromRow: Int, fromColumn: Int, toRow: Int, toColumn: Int) -> Int {
            let start = fromRow * columns + fromColumn
            let target = toRow * columns + toColumn
            if start == target { return 0 }

            currentStamp += 1
            let round = currentStamp
            stamp[start] = round
            distanceTo[start] = 0
            queue[0] = Int32(start)
            var head = 0
            var tail = 1

            while head < tail {
                let cell = Int(queue[head])
                head += 1
                let row = cell / columns
                let column = cell % columns
                let nextDistance = distanceTo[cell] + 1
                for direction in 0..<4 {
                    let neighbour: Int
                    switch direction {
                    case 0:
                        guard row > 0 else { continue }
                        neighbour = cell - columns              // up
                    case 1:
                        guard row < rows - 1 else { continue }
                        neighbour = cell + columns              // down
                    case 2:
                        guard column > 0 else { continue }
                        neighbour = cell - 1                    // left
                    default:
                        guard column < columns - 1 else { continue }
                        neighbour = cell + 1                    // right
                    }
                    guard open[neighbour], stamp[neighbour] != round else { continue }
                    if neighbour == target { return Int(nextDistance) }
                    stamp[neighbour] = round
                    distanceTo[neighbour] = nextDistance
                    queue[tail] = Int32(neighbour)
                    tail += 1
                }
            }
            return -1
        }
    }
}
