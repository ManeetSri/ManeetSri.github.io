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

func settingFirst(_ value: Tracked, to number: Int) -> Tracked {
    var result = value       // shares the caller's buffer
    result[0] = number       // so this copies
    return result
}

func setFirst(_ value: inout Tracked, to number: Int) {
    value[0] = number        // the caller's own variable, changed in place
}

var score = Tracked()
copies = 0
for round in 1...4 {
    score = settingFirst(score, to: round)
}
print("return a changed copy:", copies)

copies = 0
for round in 1...4 {
    setFirst(&score, to: round)
}
print("inout:", copies)
