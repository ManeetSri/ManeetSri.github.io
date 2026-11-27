// Generated from src/dsa/content/lessons/queues/queue-streams.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct FirstUnique {
    private var counts: [Character: Int] = [:]
    private var candidates: [Character] = []     // a head-index queue, in arrival order
    private var head = 0

    mutating func add(_ character: Character) {
        counts[character, default: 0] += 1
        if counts[character] == 1 {
            candidates.append(character)         // a new candidate joins the back
        }
        // Repeated characters at the front can never be unique again
        while head < candidates.count && counts[candidates[head], default: 0] > 1 {
            head += 1
        }
    }

    var firstUnique: Character? {
        head < candidates.count ? candidates[head] : nil
    }
}

var watcher = FirstUnique()
var answers: [String] = []
for character in "aabcbd" {
    watcher.add(character)
    answers.append(watcher.firstUnique.map { String($0) } ?? "#")
}
print(answers.joined(separator: " "))
