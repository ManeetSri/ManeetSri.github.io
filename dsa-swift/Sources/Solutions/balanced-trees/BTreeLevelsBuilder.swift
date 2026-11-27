// Reference solution: Build a B-tree, split by split. Insert recursively: find the first key ≥ the new
// one (a duplicate stops here), add it to the leaf, and on the way back up let any overfull node split,
// handing its median and new right half to its parent. A root split makes a new root, the only way the
// tree grows. Read the levels breadth first. O(n × maxKeys × log n) time, O(n) space.

public enum BTreeLevelsBuilder {
    private final class Node {
        var keys: [Int] = []
        var children: [Node] = []                        // empty for a leaf
    }

    public static func levels(afterInserting keys: [Int], maxKeys: Int) -> [[[Int]]] {
        guard !keys.isEmpty else { return [] }
        var root = Node()
        for key in keys {
            if let (median, right) = insert(key, into: root, maxKeys: maxKeys) {
                let newRoot = Node()                     // the root split: grow at the top
                newRoot.keys = [median]
                newRoot.children = [root, right]
                root = newRoot
            }
        }
        var result: [[[Int]]] = []
        var level = [root]
        while !level.isEmpty {
            result.append(level.map(\.keys))
            level = level.flatMap(\.children)
        }
        return result
    }

    /// Inserts key below node; if node overflows, splits it and returns the median and the new right half.
    private static func insert(_ key: Int, into node: Node, maxKeys: Int) -> (Int, Node)? {
        var low = 0                                      // the first key ≥ key, by binary search
        var high = node.keys.count
        while low < high {
            let mid = (low + high) / 2
            if node.keys[mid] < key { low = mid + 1 } else { high = mid }
        }
        if low < node.keys.count && node.keys[low] == key { return nil }      // already there
        if node.children.isEmpty {
            node.keys.insert(key, at: low)
        } else if let (median, right) = insert(key, into: node.children[low], maxKeys: maxKeys) {
            node.keys.insert(median, at: low)            // take in the child's median…
            node.children.insert(right, at: low + 1)     // …and its new right half
        }
        guard node.keys.count > maxKeys else { return nil }
        let mid = node.keys.count / 2
        let median = node.keys[mid]
        let right = Node()
        right.keys = Array(node.keys[(mid + 1)...])
        node.keys.removeSubrange(mid...)
        if !node.children.isEmpty {
            right.children = Array(node.children[(mid + 1)...])
            node.children.removeSubrange((mid + 1)...)
        }
        return (median, right)
    }
}
