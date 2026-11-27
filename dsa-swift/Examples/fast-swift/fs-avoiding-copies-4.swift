// Generated from src/dsa/content/lessons/fast-swift/fs-avoiding-copies.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var copies = 0

final class Buffer {
    var items: [Int]
    init(_ items: [Int]) { self.items = items }
}

struct Tracked {
    private var buffer = Buffer([0, 0, 0, 0])

    subscript(index: Int) -> Int {
        get { buffer.items[index] }
        set {
            if !isKnownUniquelyReferenced(&buffer) {
                copies += 1
                buffer = Buffer(buffer.items)
            }
            buffer.items[index] = newValue
        }
    }
}

final class Board {
    var cells = Tracked()

    func markSlowly(_ index: Int) {
        var cells = self.cells      // a second reference
        cells[index] = 1            // copies the whole buffer
        self.cells = cells
    }

    func mark(_ index: Int) {
        cells[index] = 1            // changes the stored property in place
    }
}

let board = Board()
copies = 0
for i in 0..<4 {
    board.markSlowly(i)
}
print("local copy, then write back:", copies)

copies = 0
for i in 0..<4 {
    board.mark(i)
}
print("write to the property:", copies)
