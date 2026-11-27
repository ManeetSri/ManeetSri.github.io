// Generated from src/dsa/content/lessons/strings-basic/str-isomorphic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isomorphicOneWay(_ first: String, _ second: String) -> Bool {
    let a = Array(first)
    let b = Array(second)
    guard a.count == b.count else { return false }
    var forward: [Character: Character] = [:]
    for (x, y) in zip(a, b) {
        if let mapped = forward[x], mapped != y {
            return false
        }
        forward[x] = y
    }
    return true
}

print(isomorphicOneWay("paper", "title"))
print(isomorphicOneWay("ab", "cc"))
