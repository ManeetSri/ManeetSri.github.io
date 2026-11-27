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

var history = Tracked()
let readLatest = { history[0] }               // captures the variable
copies = 0
history[0] = 1
print("after a plain capture:", copies, readLatest())

let frozen = { [history] in history[0] }      // captures the value right now
copies = 0
history[0] = 2
history[1] = 2
print("after a capture list:", copies, frozen(), readLatest())
