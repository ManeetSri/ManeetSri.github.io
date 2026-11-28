// Reference solution: Lineage queries. Binary lifting: up[k][v] is v's 2^k-th ancestor, built from
// up[k][v] = up[k - 1][up[k - 1][v]] (two jumps of 2^(k - 1)). The root is its own parent, so jumps
// past it stay put. Depths come from a BFS from the root, because parents may come after their
// children in the array and recursion would be 100,000 calls deep on a chain.
// A k-th ancestor jumps once per set bit of k. An LCA query lifts the deeper person to the same depth,
// then jumps both up by the largest powers of two that keep their ancestors different; the parent of
// where they stop is the answer. O(n log n) to build, O(log n) per query.

public enum LineageQueries {
    public static func kthAncestors(parent: [Int], queries: [[Int]]) -> [Int] {
        let lifting = Lifting(parent: parent)
        return queries.map { lifting.ancestor(of: $0[0], generationsUp: $0[1]) }
    }

    public static func lowestCommonAncestors(parent: [Int], queries: [[Int]]) -> [Int] {
        let lifting = Lifting(parent: parent)
        return queries.map { lifting.lowestCommonAncestor($0[0], $0[1]) }
    }

    private struct Lifting {
        let up: [[Int]]
        let depth: [Int]

        init(parent: [Int]) {
            let n = parent.count
            var children = [[Int]](repeating: [], count: n)
            var root = 0
            for v in 0..<n {
                if parent[v] == -1 { root = v } else { children[parent[v]].append(v) }
            }
            var depth = [Int](repeating: 0, count: n)
            var order = [root]                         // BFS order: every parent before its children
            var front = 0
            while front < order.count {
                let v = order[front]
                front += 1
                for child in children[v] {
                    depth[child] = depth[v] + 1
                    order.append(child)
                }
            }

            var levels = 1                             // enough levels that 2^levels > any depth
            while (1 << levels) < n { levels += 1 }
            var up = [(0..<n).map { parent[$0] == -1 ? $0 : parent[$0] }]
            for k in 1..<levels {
                let previous = up[k - 1]
                up.append(previous.map { previous[$0] })
            }
            self.up = up
            self.depth = depth
        }

        func ancestor(of person: Int, generationsUp k: Int) -> Int {
            if k > depth[person] { return -1 }
            var v = person
            for bit in 0..<up.count where (k >> bit) & 1 == 1 {
                v = up[bit][v]
            }
            return v
        }

        func lowestCommonAncestor(_ first: Int, _ second: Int) -> Int {
            var (u, v) = depth[first] >= depth[second] ? (first, second) : (second, first)
            u = ancestor(of: u, generationsUp: depth[u] - depth[v])
            if u == v { return u }
            for k in stride(from: up.count - 1, through: 0, by: -1) where up[k][u] != up[k][v] {
                u = up[k][u]
                v = up[k][v]
            }
            return up[0][u]
        }
    }
}
