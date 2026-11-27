// Reference solution: Fares within a price window. Each query splits into two parts with one
// threshold each: (fares ≤ high) − (fares ≤ low − 1). Offline, sort the parts by threshold and the
// days by fare, and sweep: before answering a part, mark every day with fare ≤ its threshold in a
// Fenwick tree over days, then count the marked days in left...right with two prefix sums.
// O((n + q) log n) time, O(n + q) space.

public enum FareWindowCounts {
    public static func counts(fares: [Int], queries: [[Int]]) -> [Int] {
        let n = fares.count
        var tree = [Int](repeating: 0, count: n + 1)
        func add(_ index: Int) {
            var i = index + 1
            while i <= n {
                tree[i] += 1
                i += i & -i
            }
        }
        func prefix(_ count: Int) -> Int {
            var i = count
            var total = 0
            while i > 0 {
                total += tree[i]
                i -= i & -i
            }
            return total
        }

        var parts: [(threshold: Int, query: Int, sign: Int)] = []
        parts.reserveCapacity(2 * queries.count)
        for (q, query) in queries.enumerated() {
            parts.append((query[3], q, 1))            // fares ≤ high count...
            parts.append((query[2] - 1, q, -1))       // ...minus fares ≤ low - 1
        }
        parts.sort { $0.threshold < $1.threshold }
        let days = fares.indices.sorted { fares[$0] < fares[$1] }

        var answers = [Int](repeating: 0, count: queries.count)
        var next = 0
        for part in parts {
            while next < n && fares[days[next]] <= part.threshold {
                add(days[next])
                next += 1
            }
            let left = queries[part.query][0], right = queries[part.query][1]
            answers[part.query] += part.sign * (prefix(right + 1) - prefix(left))
        }
        return answers
    }
}
