// Generated from src/dsa/content/lessons/hashing/hash-custom-keys.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node: Hashable {
    let label: String

    init(_ label: String) {
        self.label = label
    }

    static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

let first = Node("A")
let second = Node("A")
var visited: Set<Node> = [first]

print(visited.contains(first))
print(visited.contains(second))
visited.insert(second)
print(visited.count)
