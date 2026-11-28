// Reference solution: Tally the search cases. A query costs (index of its first match) + 1, or
// items.count when it's missing, so record first indexes once and look each query up.
// O(n + q) time on average, O(n) extra space.

public enum SearchCaseTally {
    public struct Tally: Equatable {
        public var best: Int
        public var worst: Int
        public var total: Int

        public init(best: Int, worst: Int, total: Int) {
            self.best = best
            self.worst = worst
            self.total = total
        }
    }

    public static func tally(items: [Int], queries: [Int]) -> Tally {
        var firstIndex: [Int: Int] = [:]
        for (index, item) in items.enumerated() where firstIndex[item] == nil {
            firstIndex[item] = index              // later duplicates are never reached
        }
        var result = Tally(best: Int.max, worst: 0, total: 0)
        for query in queries {
            let cost = firstIndex[query].map { $0 + 1 } ?? items.count
            result.best = min(result.best, cost)
            result.worst = max(result.worst, cost)
            result.total += cost
        }
        return result
    }
}
