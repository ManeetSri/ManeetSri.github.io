// Generated from src/dsa/content/lessons/fast-swift/fs-avoiding-copies.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var copies = 0

final class Buffer {
    var items: [Int]
    init(_ items: [Int]) { self.items = items }
}

// A copy-on-write value that counts every time it has to copy its buffer
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

var a = Tracked()
a[0] = 1
var b = a
b[1] = 2
b[2] = 3
print("copies:", copies)
print(a[1], b[1])
