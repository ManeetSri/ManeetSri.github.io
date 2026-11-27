// Generated from src/dsa/content/lessons/swift-memory/swift-implementing-cow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class ScoreStorage {
    var scores: [Int] = []
}

struct ScoreList {
    private var storage = ScoreStorage()

    var scores: [Int] { storage.scores }

    mutating func add(_ score: Int) {
        storage.scores.append(score)
    }
}

var a = ScoreList()
a.add(10)
var b = a          // a "copy"...
b.add(20)          // ...changed through b
print(a.scores)
print(b.scores)
