// Generated from src/dsa/content/lessons/binary-trees/bt-flatten-next.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class LevelNode {
    var value: Int
    var left: LevelNode?
    var right: LevelNode?
    var next: LevelNode?                                // the node to the right on the same level

    init(_ value: Int, left: LevelNode? = nil, right: LevelNode? = nil) {
        self.value = value
        self.left = left
        self.right = right
    }
}

func linkLevels(_ root: LevelNode?) {
    var levelStart = root
    while let start = levelStart {
        let dummy = LevelNode(0)                        // the level below gets linked up behind this
        var tail = dummy
        var current: LevelNode? = start
        while let node = current {                      // walk this level along its next links
            if let left = node.left {
                tail.next = left
                tail = left
            }
            if let right = node.right {
                tail.next = right
                tail = right
            }
            current = node.next
        }
        levelStart = dummy.next                         // the first node of the level below
    }
}

// The tree from the drawing: 1 has children 2 and 3; 2 has 4 and 5; 3 has only a right child, 7
let root = LevelNode(1, left: LevelNode(2, left: LevelNode(4), right: LevelNode(5)),
                     right: LevelNode(3, right: LevelNode(7)))
linkLevels(root)

// Print each level by following the next links
var levelStart: LevelNode? = root
while let start = levelStart {
    var values: [Int] = []
    var nextStart: LevelNode? = nil
    var node: LevelNode? = start
    while let current = node {
        values.append(current.value)
        nextStart = nextStart ?? current.left ?? current.right
        node = current.next
    }
    print(values)
    levelStart = nextStart
}
