// Generated from src/dsa/content/lessons/capstones/cap-visualiser.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A frame is one picture of the algorithm. Algorithms record frames; a player steps through them.
struct SortFrame {
    let values: [Int]
    let active: [Int]          // the indexes being compared or swapped
    let note: String
}

struct GridFrame {
    let distance: [[Int?]]     // nil: not reached yet
    let path: [Point]          // filled in on the last frame only
    let note: String
}

struct Point: Hashable {
    let row: Int
    let col: Int
}

/// Insertion sort, recording a frame for every comparison and every swap
func insertionSortFrames(_ input: [Int]) -> [SortFrame] {
    var items = input
    var frames = [SortFrame(values: items, active: [], note: "start")]
    for i in 1..<items.count {
        var j = i
        while j > 0 {
            frames.append(SortFrame(values: items, active: [j - 1, j], note: "compare"))
            guard items[j - 1] > items[j] else { break }
            items.swapAt(j - 1, j)
            frames.append(SortFrame(values: items, active: [j - 1, j], note: "swap"))
            j -= 1
        }
    }
    frames.append(SortFrame(values: items, active: [], note: "sorted"))
    return frames
}

/// BFS from S to G, recording a frame each time a whole distance layer is finished
func bfsFrames(_ rows: [String]) -> [GridFrame] {
    let grid = rows.map { Array($0) }
    var start = Point(row: 0, col: 0), goal = start
    for (r, line) in grid.enumerated() {
        for (c, cell) in line.enumerated() {
            if cell == "S" { start = Point(row: r, col: c) }
            if cell == "G" { goal = Point(row: r, col: c) }
        }
    }
    var distance: [[Int?]] = grid.map { $0.map { _ in nil } }
    var previous: [Point: Point] = [:]
    distance[start.row][start.col] = 0
    var frames = [GridFrame(distance: distance, path: [], note: "start")]
    var layer = [start]
    while !layer.isEmpty && distance[goal.row][goal.col] == nil {
        var next: [Point] = []
        for point in layer {
            for (dr, dc) in [(-1, 0), (0, 1), (1, 0), (0, -1)] {
                let r = point.row + dr, c = point.col + dc
                guard grid.indices.contains(r), grid[r].indices.contains(c),
                      grid[r][c] != "#", distance[r][c] == nil else { continue }
                distance[r][c] = distance[point.row][point.col]! + 1
                previous[Point(row: r, col: c)] = point
                next.append(Point(row: r, col: c))
            }
        }
        layer = next
        frames.append(GridFrame(distance: distance, path: [], note: "layer \(frames.count)"))
    }
    var path: [Point] = []
    var step: Point? = distance[goal.row][goal.col] == nil ? nil : goal
    while let point = step {
        path.append(point)
        step = previous[point]
    }
    frames.append(GridFrame(distance: distance, path: path.reversed(), note: "path"))
    return frames
}

/// Knows nothing about sorting or grids: it only moves through an array of frames
struct Player<Frame> {
    let frames: [Frame]
    private(set) var index = 0

    init(_ frames: [Frame]) {
        self.frames = frames
    }

    var current: Frame { frames[index] }
    var isAtEnd: Bool { index == frames.count - 1 }

    mutating func step() { index = min(index + 1, frames.count - 1) }
    mutating func back() { index = max(index - 1, 0) }
    mutating func seek(to position: Int) { index = min(max(position, 0), frames.count - 1) }
}

func render(_ frame: SortFrame) -> String {
    let bars = frame.values.indices.map { i in
        frame.active.contains(i) ? "(\(frame.values[i]))" : " \(frame.values[i]) "
    }
    return bars.joined() + "  " + frame.note
}

func render(_ frame: GridFrame, walls rows: [String]) -> [String] {
    let onPath = Set(frame.path)
    return rows.enumerated().map { r, line in
        String(line.enumerated().map { c, cell -> Character in
            if cell == "#" || cell == "S" || cell == "G" { return cell }
            if onPath.contains(Point(row: r, col: c)) { return "*" }
            if let d = frame.distance[r][c] { return Character(String(d % 10)) }
            return "."
        })
    }
}

var sorting = Player(insertionSortFrames([4, 2, 3, 1]))
print("\(sorting.frames.count) frames")
while true {
    let label = String(sorting.index)
    print(label + String(repeating: " ", count: 3 - label.count) + render(sorting.current))
    if sorting.isAtEnd { break }
    sorting.step()
}

let maze = [
    "S..#.",
    ".#...",
    ".#.#.",
    "...#G",
]
var search = Player(bfsFrames(maze))
print("\(search.frames.count) frames")
search.seek(to: 3)
print(search.current.note)
render(search.current, walls: maze).forEach { print($0) }
search.seek(to: search.frames.count - 1)
print(search.current.note, search.current.path.count - 1, "steps")
render(search.current, walls: maze).forEach { print($0) }
search.back()
print("back to", search.current.note)
