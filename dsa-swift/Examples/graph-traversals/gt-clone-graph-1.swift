// Generated from src/dsa/content/lessons/graph-traversals/gt-clone-graph.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    let value: Int
    var neighbours: [Node] = []
    init(_ value: Int) { self.value = value }
}

func cloneGraph(_ start: Node?) -> Node? {
    guard let start else { return nil }
    var copies: [ObjectIdentifier: Node] = [ObjectIdentifier(start): Node(start.value)]
    var queue = [start]
    var head = 0
    while head < queue.count {
        let original = queue[head]
        head += 1
        let copy = copies[ObjectIdentifier(original)]!
        for neighbour in original.neighbours {
            let key = ObjectIdentifier(neighbour)
            if copies[key] == nil {
                copies[key] = Node(neighbour.value)     // first sight: make its copy, then visit it
                queue.append(neighbour)
            }
            copy.neighbours.append(copies[key]!)        // link to the copy, never the original
        }
    }
    return copies[ObjectIdentifier(start)]
}

/// Every node reachable from start, in BFS order
func allNodes(from start: Node) -> [Node] {
    var seen: Set<ObjectIdentifier> = [ObjectIdentifier(start)]
    var queue = [start]
    var head = 0
    while head < queue.count {
        for next in queue[head].neighbours where seen.insert(ObjectIdentifier(next)).inserted {
            queue.append(next)
        }
        head += 1
    }
    return queue
}

// A square 1 – 2 – 3 – 4 – 1, a second node labelled 2 hanging off 3, and a loop from 4 to itself
let nodes = [Node(1), Node(2), Node(3), Node(4), Node(2)]
func link(_ a: Int, _ b: Int) {
    nodes[a].neighbours.append(nodes[b])
    if a != b { nodes[b].neighbours.append(nodes[a]) }
}
link(0, 1); link(1, 2); link(2, 3); link(3, 0); link(2, 4); link(3, 3)

let copy = cloneGraph(nodes[0])!
for (original, twin) in zip(allNodes(from: nodes[0]), allNodes(from: copy)) {
    print(original.value, original.neighbours.map(\.value), "→ copy:", twin.value, twin.neighbours.map(\.value))
}
let originalIDs = Set(allNodes(from: nodes[0]).map { ObjectIdentifier($0) })
let copyIDs = Set(allNodes(from: copy).map { ObjectIdentifier($0) })
print("nodes in the copy:", copyIDs.count, "shared with the original:", originalIDs.intersection(copyIDs).count)
print("copy of 4 links to itself:", copy.neighbours[1].neighbours[2] === copy.neighbours[1])
