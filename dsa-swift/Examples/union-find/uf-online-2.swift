// Generated from src/dsa/content/lessons/union-find/uf-online.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The UnionFind from "Path compression and union by rank"
struct UnionFind {
    private var parent: [Int]
    private var size: [Int]

    init(count: Int) {
        parent = Array(0..<count)
        size = Array(repeating: 1, count: count)
    }

    mutating func find(_ x: Int) -> Int {
        var root = x
        while parent[root] != root { root = parent[root] }
        var node = x
        while node != root {
            let next = parent[node]
            parent[node] = root
            node = next
        }
        return root
    }

    @discardableResult
    mutating func union(_ a: Int, _ b: Int) -> Bool {
        var rootA = find(a)
        var rootB = find(b)
        if rootA == rootB { return false }
        if size[rootA] < size[rootB] { swap(&rootA, &rootB) }
        parent[rootB] = rootA
        size[rootA] += size[rootB]
        return true
    }
}

func canAllHold(_ equations: [(String, String, String)]) -> Bool {
    var indexOf: [String: Int] = [:]
    for (left, _, right) in equations {
        for name in [left, right] where indexOf[name] == nil {
            indexOf[name] = indexOf.count
        }
    }
    var groups = UnionFind(count: indexOf.count)
    for (left, op, right) in equations where op == "==" {
        groups.union(indexOf[left]!, indexOf[right]!)            // pass 1: equalities
    }
    for (left, op, right) in equations where op == "!=" {
        if groups.find(indexOf[left]!) == groups.find(indexOf[right]!) {
            print("  broken: \(left) != \(right)")
            return false                                          // pass 2: inequalities
        }
    }
    return true
}

print(canAllHold([("a", "==", "b"), ("b", "!=", "c"), ("c", "==", "d")]))
print(canAllHold([("x", "!=", "z"), ("x", "==", "y"), ("y", "==", "z")]))
print(canAllHold([("p", "!=", "q"), ("q", "!=", "r"), ("r", "!=", "p")]))
print(canAllHold([("n", "!=", "n")]))
