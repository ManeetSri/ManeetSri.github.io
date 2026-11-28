// Generated from src/dsa/content/lessons/union-find/uf-rollback-weighted.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct RollbackUnionFind {
    private(set) var parent: [Int]
    private var size: [Int]
    private var history: [(child: Int, root: Int)?] = []   // nil: a union that changed nothing
    private(set) var componentCount: Int

    init(count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
        componentCount = count
    }

    /// No path compression, so find changes nothing: O(log n) thanks to union by size
    func find(_ x: Int) -> Int {
        var node = x
        while parent[node] != node { node = parent[node] }
        return node
    }

    @discardableResult
    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var rootA = find(a)
        var rootB = find(b)
        if rootA == rootB {
            history.append(nil)                  // still recorded, so every union can be undone
            return false
        }
        if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
        parent[rootB] = rootA
        size[rootA] += size[rootB]
        componentCount -= 1
        history.append((child: rootB, root: rootA))
        return true
    }

    /// A marker to roll back to: the number of unions so far
    var snapshot: Int { history.count }

    /// Undoes unions, most recent first, until only `snapshot` remain. O(1) per union undone.
    mutating func rollback(to snapshot: Int) {
        while history.count > snapshot {
            guard let change = history.removeLast() else { continue }
            parent[change.child] = change.child
            size[change.root] -= size[change.child]
            componentCount += 1
        }
    }
}

var sets = RollbackUnionFind(count: 6)
sets.union(0, 1)
sets.union(2, 3)
let checkpoint = sets.snapshot
print("checkpoint:", sets.parent, "sets:", sets.componentCount)
sets.union(1, 2)
sets.union(4, 5)
sets.union(0, 3)                                 // already joined: recorded as nil
print("3 unions on:", sets.parent, "sets:", sets.componentCount, "| 0 and 3 together?", sets.find(0) == sets.find(3))
sets.rollback(to: checkpoint)
print("rolled back:", sets.parent, "sets:", sets.componentCount, "| 0 and 3 together?", sets.find(0) == sets.find(3))
