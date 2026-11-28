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

var rows = (0..<3).map { _ in Tracked() }       // three rows, three separate buffers

copies = 0
for r in 0..<3 {
    var row = rows[r]        // a second reference to the row's buffer
    row[0] = 1               // shared, so this copies the whole row
    rows[r] = row
}
print("take out, change, put back:", copies)

copies = 0
for r in 0..<3 {
    rows[r][1] = 1           // changes the row where it lives
}
print("change in place:", copies)
