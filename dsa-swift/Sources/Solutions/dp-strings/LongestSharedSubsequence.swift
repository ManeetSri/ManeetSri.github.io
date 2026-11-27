// Reference solution: Longest shared subsequence. table[i][j] is the LCS length of the first i
// characters of one string and the first j of the other: a matching last pair extends the diagonal,
// otherwise drop the last character of one string or the other. Walking back from the corner through
// the matches spells one longest subsequence. O(n · m) time and space; the length alone needs two rows.

public enum LongestSharedSubsequence {
    public static func length(_ first: String, _ second: String) -> Int {
        let a = Array(first), b = Array(second)
        var previous = Array(repeating: 0, count: b.count + 1)
        var current = previous
        for i in 0..<a.count {
            for j in 1..<(b.count + 1) {
                current[j] = a[i] == b[j - 1] ? previous[j - 1] + 1 : max(previous[j], current[j - 1])
            }
            swap(&previous, &current)
        }
        return previous[b.count]
    }

    public static func oneLongest(_ first: String, _ second: String) -> String {
        let a = Array(first), b = Array(second)
        let n = a.count, m = b.count
        var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
        for i in 0...n {
            for j in 0...m {
                if i == 0 || j == 0 {
                    table[i][j] = 0
                } else if a[i - 1] == b[j - 1] {
                    table[i][j] = table[i - 1][j - 1] + 1
                } else {
                    table[i][j] = max(table[i - 1][j], table[i][j - 1])
                }
            }
        }
        var letters: [Character] = []
        var i = n, j = m
        while i > 0 && j > 0 {
            if a[i - 1] == b[j - 1] {
                letters.append(a[i - 1])
                i -= 1
                j -= 1
            } else if table[i - 1][j] >= table[i][j - 1] {
                i -= 1
            } else {
                j -= 1
            }
        }
        return String(letters.reversed())
    }
}
