// Generated from src/dsa/content/lessons/matrices/matrix-directions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let fourWay = [(-1, 0), (0, 1), (1, 0), (0, -1)]
let eightWay = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
let rows = 3
let columns = 4

func isInside(_ row: Int, _ column: Int) -> Bool {
    row >= 0 && row < rows && column >= 0 && column < columns
}

func neighbours(of row: Int, _ column: Int, moves: [(Int, Int)]) -> [(Int, Int)] {
    var result: [(Int, Int)] = []
    for (dr, dc) in moves where isInside(row + dr, column + dc) {
        result.append((row + dr, column + dc))
    }
    return result
}

for (row, column) in [(0, 0), (0, 2), (1, 1)] {
    let four = neighbours(of: row, column, moves: fourWay).count
    let eight = neighbours(of: row, column, moves: eightWay).count
    print("(\(row), \(column)): \(four) of 4, \(eight) of 8")
}
print(neighbours(of: 0, 0, moves: fourWay))
