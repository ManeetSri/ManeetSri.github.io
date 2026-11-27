// Generated from src/dsa/content/lessons/complexity/bigo-swift-hidden-costs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var elementHashes = 0

struct Tracked: Hashable {
    let value: Int

    func hash(into hasher: inout Hasher) {
        elementHashes += 1
        hasher.combine(value)
    }
}

let longKey = (0..<1_000).map { Tracked(value: $0) }
var scores: [[Tracked]: Int] = [longKey: 7]

elementHashes = 0
print(scores[longKey] ?? 0)
print("elements hashed for one lookup:", elementHashes)
