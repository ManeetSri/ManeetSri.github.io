// Generated from src/dsa/content/lessons/binary-search/bs-sqrt-matrix.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func contains(_ target: Int, in grid: [[Int]]) -> Bool {
    guard let firstRow = grid.first, !firstRow.isEmpty else { return false }
    let columns = firstRow.count
    var low = 0
    var high = grid.count * columns - 1            // positions in row-major order
    while low <= high {
        let mid = low + (high - low) / 2
        let value = grid[mid / columns][mid % columns]
        print("  position \(mid) is row \(mid / columns), column \(mid % columns): \(value)")
        if value == target {
            return true
        } else if value < target {
            low = mid + 1
        } else {
            high = mid - 1
        }
    }
    return false
}

let grid = [
    [2, 4, 7, 11],
    [14, 18, 21, 25],
    [30, 33, 41, 49],
]
print(contains(21, in: grid))
print(contains(26, in: grid))
