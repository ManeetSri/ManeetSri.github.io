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

var groups: [String: Tracked] = ["a": Tracked()]

copies = 0
for i in 0..<4 {
    var group = groups["a"] ?? Tracked()
    group[i] = 1
    groups["a"] = group
}
print("read, change, write back:", copies)

copies = 0
for i in 0..<4 {
    groups["a", default: Tracked()][i] = 2
}
print("default subscript:", copies)

copies = 0
for i in 0..<4 {
    groups["a"]?[i] = 3
}
print("optional chaining:", copies)

copies = 0
var taken = groups.removeValue(forKey: "a") ?? Tracked()
taken[0] = 4
groups["a"] = taken
print("remove, change, put back:", copies)
