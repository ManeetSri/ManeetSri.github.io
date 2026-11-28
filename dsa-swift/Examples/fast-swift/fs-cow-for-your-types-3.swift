// Generated from src/dsa/content/lessons/fast-swift/fs-cow-for-your-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var copies = 0

final class RowStorage {
    var cells: [Int]
    init(_ cells: [Int]) { self.cells = cells }
}

struct Row {
    private var storage = RowStorage([0, 0, 0])

    subscript(column: Int) -> Int {
        get { storage.cells[column] }
        set {
            if !isKnownUniquelyReferenced(&storage) {
                copies += 1
                storage = RowStorage(storage.cells)
            }
            storage.cells[column] = newValue
        }
    }
}

struct Board {
    private var rows = [Row(), Row(), Row()]
    private(set) var edits = 0

    subscript(row: Int) -> Row {
        get { rows[row] }
        set {
            rows[row] = newValue
            edits += 1
        }
    }
}

struct FastBoard {
    private var rows = [Row(), Row(), Row()]
    private(set) var edits = 0

    subscript(row: Int) -> Row {
        get { rows[row] }
        _modify {
            yield &rows[row]     // lend the stored row itself
            edits += 1           // runs after the caller's change has finished
        }
    }
}

var board = Board()
copies = 0
for column in 0..<3 {
    board[1][column] = 7
}
print("get and set:", copies, "copies,", board.edits, "edits")

var fast = FastBoard()
copies = 0
for column in 0..<3 {
    fast[1][column] = 7
}
print("_modify:", copies, "copies,", fast.edits, "edits")
print(fast[1][2], fast[0][2])
