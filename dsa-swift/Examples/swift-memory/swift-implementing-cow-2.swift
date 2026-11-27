// Generated from src/dsa/content/lessons/swift-memory/swift-implementing-cow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ScoreStorage {
    var scores: [Int]
    init(scores: [Int]) { self.scores = scores }
}

struct ScoreList {
    private var storage = ScoreStorage(scores: [])

    var scores: [Int] { storage.scores }

    private mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&storage) {
            print("  copying storage")
            storage = ScoreStorage(scores: storage.scores)
        }
    }

    mutating func add(_ score: Int) {
        makeUnique()
        storage.scores.append(score)
    }
}

var a = ScoreList()
print("a.add(10)")
a.add(10)
var b = a
print("b = a, then read b")
print(b.scores)
print("b.add(20)")
b.add(20)
print("b.add(30)")
b.add(30)
print("a.add(40)")
a.add(40)
print(a.scores, b.scores)
