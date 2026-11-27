// Reference solution: Myers' edit count with a budget. Lines are first mapped to Ints, so comparisons
// are cheap. Round d of Myers' search finds, for every diagonal k = x - y from -d to d, the furthest x
// reachable with exactly d insertions and deletions, then slides along the free "snake" of equal lines.
// The first round that reaches (n, m) is the answer. Stopping after round `limit` bounds the work at
// O((n + m) · limit) time and O(limit) space, however different the files are.

public enum MyersEditBudget {
    public static func distance(from old: [String], to new: [String], limit: Int) -> Int? {
        // Number the distinct lines, so the snakes compare Ints instead of Strings
        guard limit >= 0 else { return nil }
        var ids: [String: Int] = [:]
        func id(_ line: String) -> Int {
            if let known = ids[line] { return known }
            ids[line] = ids.count
            return ids.count - 1
        }
        let a = old.map(id), b = new.map(id)
        let n = a.count, m = b.count
        let rounds = min(limit, n + m)
        let offset = rounds + 1
        var v = [Int](repeating: 0, count: 2 * rounds + 3)     // v[offset + k]: furthest x on diagonal k
        for d in 0...rounds {
            for k in stride(from: -d, through: d, by: 2) {
                var x: Int
                if k == -d || (k != d && v[offset + k - 1] < v[offset + k + 1]) {
                    x = v[offset + k + 1]                         // down from diagonal k + 1: an insertion
                } else {
                    x = v[offset + k - 1] + 1                     // right from diagonal k - 1: a deletion
                }
                var y = x - k
                while x < n && y < m && a[x] == b[y] {            // the snake: equal lines are free
                    x += 1
                    y += 1
                }
                v[offset + k] = x
                if x >= n && y >= m { return d }
            }
        }
        return nil
    }
}
