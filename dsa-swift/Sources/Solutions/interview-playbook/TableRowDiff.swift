// Reference solution: table row diff. The rows that can stay are a common subsequence of the two lists,
// so the fewest changes keep a *longest* common subsequence: every other old row is a deletion and every
// other new row an insertion. `keep[i][j]` (flattened) is the LCS length of old[i...] and new[j...];
// filling it from the back lets one walk from the front read off the choices in index order.
// O(n · m) time and space. Because ids are unique, an LIS over old positions would also work in
// O((n + m) log n), as the statement's second approach shows.

public enum TableRowDiff {
    public struct Changes: Equatable, CustomStringConvertible {
        public var deletions: [Int]
        public var insertions: [Int]

        public init(deletions: [Int], insertions: [Int]) {
            self.deletions = deletions
            self.insertions = insertions
        }

        public var description: String { "deletions \(deletions), insertions \(insertions)" }
    }

    public static func changes(from old: [String], to new: [String]) -> Changes {
        let n = old.count, m = new.count
        let width = m + 1
        var keep = Array(repeating: 0, count: (n + 1) * width)
        for i in stride(from: n - 1, through: 0, by: -1) {
            for j in stride(from: m - 1, through: 0, by: -1) {
                keep[i * width + j] = old[i] == new[j]
                    ? keep[(i + 1) * width + j + 1] + 1
                    : max(keep[(i + 1) * width + j], keep[i * width + j + 1])
            }
        }

        var changes = Changes(deletions: [], insertions: [])
        var i = 0, j = 0
        while i < n && j < m {
            if old[i] == new[j] {
                i += 1
                j += 1
            } else if keep[(i + 1) * width + j] >= keep[i * width + j + 1] {
                changes.deletions.append(i)      // skipping old[i] loses nothing
                i += 1
            } else {
                changes.insertions.append(j)
                j += 1
            }
        }
        changes.deletions += Array(i..<n)
        changes.insertions += Array(j..<m)
        return changes
    }
}
