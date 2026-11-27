// Reference solution: Exchange-rate queries. A weighted union-find: every currency stores its parent
// and how many units of the parent one unit of it buys. Multiplying those factors up the path gives
// a currency's value in units of its set's root, and find compresses the path while keeping the
// products right. Two currencies have a known rate exactly when they share a root, and then
// 1 c = value(c) / value(d) units of d. O((r + q) α(n)) time for r rates and q queries, O(n) space.

public enum ExchangeRateQueries {
    /// Weighted union-find over currency indices, with path compression and union by size.
    private struct RatioSets {
        var parent: [Int] = []
        var factor: [Double] = []     // one unit of x buys factor[x] units of parent[x]
        var size: [Int] = []

        mutating func add() -> Int {
            parent.append(parent.count)
            factor.append(1)
            size.append(1)
            return parent.count - 1
        }

        /// The root of x and the value of one x in units of that root.
        mutating func find(_ x: Int) -> (root: Int, value: Double) {
            var path: [Int] = []
            var root = x
            while parent[root] != root {
                path.append(root)
                root = parent[root]
            }
            // Compress from the node nearest the root down, so each factor already points at the root
            for node in path.reversed() where parent[node] != root {
                factor[node] *= factor[parent[node]]
                parent[node] = root
            }
            return (root, x == root ? 1 : factor[x])
        }

        /// Records that one a buys rate units of b.
        mutating func union(_ a: Int, _ b: Int, rate: Double) {
            let (rootA, valueA) = find(a)
            let (rootB, valueB) = find(b)
            guard rootA != rootB else { return }
            // a = valueA · rootA and b = valueB · rootB, with a = rate · b,
            // so one rootA buys rate · valueB / valueA units of rootB, and the reverse for rootB
            if size[rootA] < size[rootB] {
                parent[rootA] = rootB
                factor[rootA] = rate * valueB / valueA
                size[rootB] += size[rootA]
            } else {
                parent[rootB] = rootA
                factor[rootB] = valueA / (rate * valueB)
                size[rootA] += size[rootB]
            }
        }
    }

    public static func answer(rates: [(String, String, Double)], queries: [(String, String)]) -> [Double] {
        var sets = RatioSets()
        var indexOf: [String: Int] = [:]
        func index(of name: String) -> Int {
            if let index = indexOf[name] { return index }
            let index = sets.add()
            indexOf[name] = index
            return index
        }
        for (from, to, rate) in rates {
            sets.union(index(of: from), index(of: to), rate: rate)
        }
        return queries.map { from, to in
            guard let a = indexOf[from], let b = indexOf[to] else { return -1 }
            let (rootA, valueA) = sets.find(a)
            let (rootB, valueB) = sets.find(b)
            return rootA == rootB ? valueA / valueB : -1
        }
    }
}
