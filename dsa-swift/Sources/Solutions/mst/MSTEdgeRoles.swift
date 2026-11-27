// Reference solution: Critical and optional links. First find the MST weight with Kruskal. A link is
// critical when leaving it out makes the best spanning tree heavier, or impossible. A link that
// isn't critical is optional (pseudo-critical) when forcing it into the tree first still reaches the
// minimum weight: then some MST uses it. Each test is one more Kruskal pass over the edges, which
// are sorted once, so it's O(E log E + E² α(n)) time and O(n + E) space.

import DSAKit

public enum MSTEdgeRoles {
    public static func classify(_ n: Int, _ edges: [[Int]]) -> (critical: [Int], pseudoCritical: [Int]) {
        let order = edges.indices.sorted { edges[$0][2] < edges[$1][2] }

        /// The weight of the lightest spanning tree that leaves out `skipped` and starts with
        /// `forced`, or nil if no spanning tree exists without `skipped`.
        func treeWeight(skipping skipped: Int? = nil, forcing forced: Int? = nil) -> Int? {
            var nodes = UnionFind(count: n)
            var total = 0
            if let forced {
                nodes.union(edges[forced][0], edges[forced][1])
                total += edges[forced][2]
            }
            for index in order where index != skipped && nodes.componentCount > 1 {
                if nodes.union(edges[index][0], edges[index][1]) {
                    total += edges[index][2]
                }
            }
            return nodes.componentCount == 1 ? total : nil
        }

        guard let best = treeWeight() else { return ([], []) }
        var critical: [Int] = []
        var pseudoCritical: [Int] = []
        for index in edges.indices {
            if let without = treeWeight(skipping: index), without == best {
                if treeWeight(forcing: index) == best {
                    pseudoCritical.append(index)
                }
            } else {
                critical.append(index)
            }
        }
        return (critical, pseudoCritical)
    }
}
