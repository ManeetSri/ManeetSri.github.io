// Generated from src/dsa/content/lessons/fast-swift/fs-cow-for-your-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class MatrixStorage {
    var cells: [Double]
    init(cells: [Double]) { self.cells = cells }
}

struct Matrix {
    private var storage = MatrixStorage(cells: [0, 0, 0, 0])

    // For tests: the identity of the storage object, which doesn't keep it alive
    var storageID: ObjectIdentifier { ObjectIdentifier(storage) }

    // For tests: must be mutating, because the check needs inout access
    mutating func isUniquelyStored() -> Bool {
        isKnownUniquelyReferenced(&storage)
    }

    subscript(index: Int) -> Double {
        get { storage.cells[index] }
        set {
            if !isKnownUniquelyReferenced(&storage) {
                storage = MatrixStorage(cells: storage.cells)
            }
            storage.cells[index] = newValue
        }
    }
}

var a = Matrix()
let before = a.storageID
a[0] = 1
print("in place:", a.storageID == before)
print("unique:", a.isUniquelyStored())

let b = a
print("unique while b exists:", a.isUniquelyStored())
a[1] = 2
print("in place:", a.storageID == before)
print("b kept the old storage:", b.storageID == before, b[1])
