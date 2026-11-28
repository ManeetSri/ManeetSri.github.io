// Generated from src/dsa/content/lessons/swift-memory/swift-implementing-cow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class RowStorage {
    var cells: [Int]
    init(cells: [Int]) { self.cells = cells }
}

struct Row {
    private var storage: RowStorage

    init(count: Int) {
        storage = RowStorage(cells: Array(repeating: 0, count: count))
    }

    subscript(index: Int) -> Int {
        get { storage.cells[index] }
        set {
            if !isKnownUniquelyReferenced(&storage) {
                print("  copying storage")
                storage = RowStorage(cells: storage.cells)
            }
            storage.cells[index] = newValue
        }
    }
}

var first = Row(count: 3)
first[0] = 5
var second = first
print(second[0])
second[1] = 9
second[2] += 1
print(first[0], first[1], first[2])
print(second[0], second[1], second[2])
