// Generated from src/dsa/content/lessons/concurrent-structures/cc-parallel-algorithms.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Cell: Hashable, Sendable {
    let row: Int
    let column: Int
}

let rows = [
    "S..#....",
    ".#.#.##.",
    ".#...#..",
    "...#...#",
    "##.#.#..",
    "...#...G",
]
let grid = rows.map { Array($0) }

func neighbours(of cell: Cell) -> [Cell] {
    [(0, 1), (1, 0), (0, -1), (-1, 0)].compactMap { step in
        let next = Cell(row: cell.row + step.0, column: cell.column + step.1)
        guard next.row >= 0, next.row < grid.count, next.column >= 0, next.column < grid[0].count,
              grid[next.row][next.column] != "#" else { return nil }
        return next
    }
}

/// One level's work: each chunk of the frontier, in its own child task, reports the neighbours
/// that were undiscovered when the level began. Children only read `distance`.
func discover(_ frontier: [Cell], distance: [[Int]], chunkSize: Int) async -> [[Cell]] {
    let starts = Array(stride(from: 0, to: frontier.count, by: chunkSize))
    return await withTaskGroup(of: (index: Int, found: [Cell]).self) { group in
        for (index, start) in starts.enumerated() {
            let chunk = frontier[start..<min(start + chunkSize, frontier.count)]
            group.addTask {
                let found = chunk.flatMap(neighbours).filter { distance[$0.row][$0.column] == -1 }
                return (index, found)
            }
        }
        var byChunk = Array(repeating: [Cell](), count: starts.count)
        for await result in group {
            byChunk[result.index] = result.found
        }
        return byChunk
    }
}

func parallelDistances(from start: Cell, chunkSize: Int) async -> [[Int]] {
    var distance = grid.map { $0.map { _ in -1 } }
    distance[start.row][start.column] = 0
    var frontier = [start]
    var level = 0
    while !frontier.isEmpty {
        let found = await discover(frontier, distance: distance, chunkSize: chunkSize)
        var next: [Cell] = []
        for cell in found.joined() where distance[cell.row][cell.column] == -1 {
            distance[cell.row][cell.column] = level + 1      // only the parent writes
            next.append(cell)
        }
        frontier = next
        level += 1
    }
    return distance
}

let distance = await parallelDistances(from: Cell(row: 0, column: 0), chunkSize: 2)
for row in distance {
    print(row.map { $0 < 0 ? " #" : ($0 < 10 ? " \($0)" : "\($0)") }.joined(separator: " "))
}
print("goal:", distance[5][7])
