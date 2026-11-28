// Generated from src/dsa/content/lessons/fast-swift/fs-cow-for-your-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var storageCopies = 0
var uniquenessChecks = 0

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
        uniquenessChecks += 1
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

    // One check per cell, and a full copy first if the storage is shared
    mutating func scaleCellByCell(by factor: Double) {
        for row in 0..<rows {
            for column in 0..<columns {
                self[row, column] *= factor
            }
        }
    }

    // One check, then either a plain loop or a single pass that builds new storage
    mutating func scale(by factor: Double) {
        uniquenessChecks += 1
        if isKnownUniquelyReferenced(&storage) {
            for index in storage.cells.indices {
                storage.cells[index] *= factor
            }
        } else {
            storage = MatrixStorage(cells: storage.cells.map { $0 * factor })
        }
    }
}

let original = Matrix(rows: 3, columns: 3)

var first = original
uniquenessChecks = 0
storageCopies = 0
first.scaleCellByCell(by: 2)
print("cell by cell:", uniquenessChecks, "checks,", storageCopies, "copy")

var second = original
uniquenessChecks = 0
storageCopies = 0
second.scale(by: 2)
print("whole matrix:", uniquenessChecks, "check,", storageCopies, "copies")
