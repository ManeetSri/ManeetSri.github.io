// Generated from src/dsa/content/lessons/advanced-structures/as-interval-tree.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

// A BST of closed intervals ordered by start, where every node also knows the latest end below it
final class IntervalTree {
    final class Node {
        let start: Int
        let end: Int
        let label: String
        var maxEnd: Int                          // the largest end in this node's subtree
        var left: Node?
        var right: Node?

        init(_ start: Int, _ end: Int, _ label: String) {
            self.start = start
            self.end = end
            self.label = label
            maxEnd = end
        }
    }

    private var root: Node?
    var visited = 0                              // nodes looked at by queries

    func insert(_ start: Int, _ end: Int, _ label: String) {
        root = insert(Node(start, end, label), into: root)
    }

    private func insert(_ new: Node, into node: Node?) -> Node {
        guard let node else { return new }
        if (new.start, new.label) < (node.start, node.label) {
            node.left = insert(new, into: node.left)
        } else {
            node.right = insert(new, into: node.right)
        }
        node.maxEnd = max(node.maxEnd, new.end)  // the new interval is now below this node
        return node
    }

    // Every interval that shares at least one point with start...end, in order of start
    func overlapping(_ start: Int, _ end: Int) -> [String] {
        var result: [String] = []
        func search(_ node: Node?) {
            guard let node else { return }
            visited += 1
            if node.maxEnd < start { return }    // everything here ends too early: skip it all
            search(node.left)
            if node.start <= end && start <= node.end {
                result.append(node.label)
            }
            if node.start <= end {               // the right side starts at node.start or later
                search(node.right)
            }
        }
        search(root)
        return result
    }
}

// Clips on a video timeline, by frame number
let timeline = IntervalTree()
let clips = [(240, 719, "interview"), (0, 239, "intro"), (1080, 1199, "credits"), (0, 1199, "music"),
             (400, 520, "b-roll"), (0, 47, "title"), (1100, 1199, "logo")]
for (start, end, label) in clips {
    timeline.insert(start, end, label)
}
print("frame 450:", timeline.overlapping(450, 450))
print("frames 700...1090:", timeline.overlapping(700, 1090))
print("frame 1200:", timeline.overlapping(1200, 1200))

// 20,000 random intervals: how much of the tree does a query look at?
var generator = SeededGenerator(state: 33)
var all: [(Int, Int)] = []
let big = IntervalTree()
for index in 0..<20_000 {
    let start = Int(generator.next() % 1_000_000)
    let end = start + Int(generator.next() % 1_000)
    all.append((start, end))
    big.insert(start, end, String(index))
}
var matches = true
var found = 0
for _ in 0..<1_000 {
    let point = Int(generator.next() % 1_000_000)
    let answer = big.overlapping(point, point)
    let expected = all.indices.filter { all[$0].0 <= point && point <= all[$0].1 }.count
    found += answer.count
    if answer.count != expected { matches = false }
}
print("matches brute force:", matches)
print("average found:", found / 1_000, " average nodes visited:", big.visited / 1_000, "of", all.count)
