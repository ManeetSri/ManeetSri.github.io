// Reference solution: Stacking crates. Only the crates' edges matter, so compress every left and
// right edge to its rank among all the edges: crate [left, side] then covers the gaps between
// consecutive edges with ranks rank(left) ..< rank(left + side). Keep the stack height over each gap in
// a lazy segment tree with "set a range to a height" and "maximum of a range". A crate lands on the
// tallest point under it, so its top is that maximum plus its side, and every gap it covers becomes
// that height. The answer after each drop is the running maximum of the tops.
// O(n log n) time, O(n) space.

public enum StackingCrates {
    public static func tallestAfterEachDrop(_ crates: [[Int]]) -> [Int] {
        // Coordinate compression: the sorted distinct edges, and a binary search to rank each one
        var edges: [Int] = []
        for crate in crates {
            edges.append(crate[0])
            edges.append(crate[0] + crate[1])
        }
        edges = Array(Set(edges)).sorted()
        func rank(_ x: Int) -> Int {
            var low = 0, high = edges.count
            while low < high {
                let mid = (low + high) / 2
                if edges[mid] < x { low = mid + 1 } else { high = mid }
            }
            return low
        }

        var heights = Heights(count: max(1, edges.count - 1))   // one slot per gap between edges
        var tallest = 0
        var result: [Int] = []
        result.reserveCapacity(crates.count)
        for crate in crates {
            let first = rank(crate[0]), last = rank(crate[0] + crate[1]) - 1   // the gaps it covers
            let top = heights.maximum(first, last) + crate[1]
            heights.assign(top, first, last)
            tallest = max(tallest, top)
            result.append(tallest)
        }
        return result
    }

    /// Range assignment and range maximum, with lazy tags. Recursive, nodes numbered from 1.
    private struct Heights {
        private var maximums: [Int]
        private var assigned: [Int?]                       // a pending "set everything to this"
        private let count: Int

        init(count: Int) {
            self.count = count
            maximums = Array(repeating: 0, count: 4 * count)
            assigned = Array(repeating: nil, count: 4 * count)
        }

        mutating func maximum(_ left: Int, _ right: Int) -> Int {
            maximum(left, right, 1, 0, count - 1)
        }

        mutating func assign(_ value: Int, _ left: Int, _ right: Int) {
            assign(value, left, right, 1, 0, count - 1)
        }

        private mutating func apply(_ value: Int, _ node: Int) {
            maximums[node] = value                         // every gap below is now exactly value
            assigned[node] = value                         // a newer assignment replaces an older one
        }

        private mutating func push(_ node: Int) {
            guard let value = assigned[node] else { return }
            apply(value, 2 * node)
            apply(value, 2 * node + 1)
            assigned[node] = nil
        }

        private mutating func maximum(_ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) -> Int {
            if right < low || high < left { return 0 }
            if left <= low && high <= right { return maximums[node] }
            push(node)
            let mid = (low + high) / 2
            return max(maximum(left, right, 2 * node, low, mid), maximum(left, right, 2 * node + 1, mid + 1, high))
        }

        private mutating func assign(_ value: Int, _ left: Int, _ right: Int, _ node: Int, _ low: Int, _ high: Int) {
            if right < low || high < left { return }
            if left <= low && high <= right {
                apply(value, node)
                return
            }
            push(node)
            let mid = (low + high) / 2
            assign(value, left, right, 2 * node, low, mid)
            assign(value, left, right, 2 * node + 1, mid + 1, high)
            maximums[node] = max(maximums[2 * node], maximums[2 * node + 1])
        }
    }
}
