// Generated from src/dsa/content/lessons/fast-swift/fs-cow-for-your-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var storageCopies = 0

final class MatrixStorage {
    var cells: [Double]
    init(cells: [Double]) { self.cells = cells }
}

struct Matrix {
    let rows: Int
    let columns: Int
    private var storage: MatrixStorage

    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        storage = MatrixStorage(cells: Array(repeating: 0, count: rows * columns))
    }

    private mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            storageCopies += 1
            storage = MatrixStorage(cells: storage.cells)
        }
    }

    subscript(row: Int, column: Int) -> Double {
        get { storage.cells[row * columns + column] }
        set {
            makeUnique()
            storage.cells[row * columns + column] = newValue
        }
    }
}

var identity = Matrix(rows: 3, columns: 3)
for i in 0..<3 {
    identity[i, i] = 1
}
var doubled = identity
for i in 0..<3 {
    doubled[i, i] = 2
}
print("copies:", storageCopies)
print(identity[1, 1], doubled[1, 1])
