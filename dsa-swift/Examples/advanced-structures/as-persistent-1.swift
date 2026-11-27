// Generated from src/dsa/content/lessons/advanced-structures/as-persistent.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// An immutable node: a leaf holds a value, an inner node holds two children. Nothing can change it.
final class Node {
    static var created = 0
    let left: Node?
    let right: Node?
    let value: Int

    init(value: Int) {
        left = nil
        right = nil
        self.value = value
        Node.created += 1
    }

    init(left: Node, right: Node) {
        self.left = left
        self.right = right
        value = 0
        Node.created += 1
    }
}

// An array of 2^depth Ints stored in a perfect binary tree. The bits of an index, from the top,
// say which way to turn: 0 means left, 1 means right.
struct PersistentArray {
    let root: Node
    let depth: Int

    init(repeating value: Int, depth: Int) {
        func build(_ level: Int) -> Node {
            level == 0 ? Node(value: value) : Node(left: build(level - 1), right: build(level - 1))
        }
        root = build(depth)
        self.depth = depth
    }

    private init(root: Node, depth: Int) {
        self.root = root
        self.depth = depth
    }

    subscript(index: Int) -> Int {
        var node = root
        for level in stride(from: depth - 1, through: 0, by: -1) {
            node = (index >> level) & 1 == 0 ? node.left! : node.right!
        }
        return node.value
    }

    // A new version with one element changed: copy the path to it, share everything else
    func setting(_ index: Int, to value: Int) -> PersistentArray {
        func set(_ node: Node, _ level: Int) -> Node {
            if level == 0 { return Node(value: value) }
            if (index >> (level - 1)) & 1 == 0 {
                return Node(left: set(node.left!, level - 1), right: node.right!)
            }
            return Node(left: node.left!, right: set(node.right!, level - 1))
        }
        return PersistentArray(root: set(root, depth), depth: depth)
    }
}

// Nodes reachable from a but not shared with b: walk both, skipping identical subtrees
func unshared(_ a: Node?, _ b: Node?) -> Int {
    guard let a else { return 0 }
    if a === b { return 0 }
    return 1 + unshared(a.left, b?.left) + unshared(a.right, b?.right)
}

// 1,000 versions of a 1,024-element array, each changing one element
var versions = [PersistentArray(repeating: 0, depth: 10)]
print("first version:", Node.created, "nodes")
Node.created = 0
for step in 1...1_000 {
    versions.append(versions.last!.setting((step * 37) % 1_024, to: step))
}
print("1,000 more versions:", Node.created, "new nodes,", Node.created / 1_000, "per version")
print("index 136 in versions 0, 999 and 1000:", versions[0][136], versions[999][136], versions[1_000][136])
print("nodes in version 1000 not shared with 999:", unshared(versions[1_000].root, versions[999].root))

// The same history with Array: each version's first write copies the whole shared buffer
var arrays = [Array(repeating: 0, count: 1_024)]
var copied = 0
for step in 1...1_000 {
    var next = arrays.last!                      // shares the buffer: no copy yet
    next[(step * 37) % 1_024] = step             // copy-on-write: all 1,024 elements are copied here
    copied += next.count
    arrays.append(next)
}
print("Array: \(copied) elements copied; index 136 in version 1000:", arrays[1_000][136])
