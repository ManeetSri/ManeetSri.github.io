// Generated from src/dsa/content/lessons/bs-on-answer/bsa-kth-multiplication.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countAtMost(_ x: Int, in matrix: [[Int]]) -> Int {
    var count = 0
    var row = matrix.count - 1
    var column = 0
    while row >= 0 && column < matrix[0].count {
        if matrix[row][column] <= x {
            count += row + 1             // this entry and everything above it
            column += 1
        } else {
            row -= 1
        }
    }
    return count
}

func kthSmallest(in matrix: [[Int]], k: Int) -> Int {
    var low = matrix[0][0]                                   // the smallest entry
    var high = matrix[matrix.count - 1][matrix[0].count - 1] // the largest entry
    while low < high {
        let mid = low + (high - low) / 2
        if countAtMost(mid, in: matrix) >= k {
            high = mid
        } else {
            low = mid + 1
        }
    }
    return low
}

let matrix = [
    [2, 5, 9],
    [4, 7, 13],
    [8, 11, 15],
]
print((1...9).map { kthSmallest(in: matrix, k: $0) })
