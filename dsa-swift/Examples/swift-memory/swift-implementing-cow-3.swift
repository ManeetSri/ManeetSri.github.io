// Generated from src/dsa/content/lessons/swift-memory/swift-implementing-cow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ScoreStorage {
    var scores: [Int]
    init(scores: [Int]) { self.scores = scores }
}

struct ScoreList {
    private var storage = ScoreStorage(scores: [])

    var scores: [Int] { storage.scores }

    func isSharingStorage(with other: ScoreList) -> Bool {
        ObjectIdentifier(storage) == ObjectIdentifier(other.storage)
    }

    private mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = ScoreStorage(scores: storage.scores)
        }
    }

    mutating func add(_ score: Int) {
        makeUnique()
        storage.scores.append(score)
    }

    mutating func removeLast() -> Int? {
        makeUnique()
        return storage.scores.popLast()
    }
}

var a = ScoreList()
a.add(1)
a.add(2)
var b = a
print("after b = a:", a.isSharingStorage(with: b))
let last = b.removeLast()
print("after b.removeLast():", a.isSharingStorage(with: b))
print(a.scores, b.scores, last ?? -1)
