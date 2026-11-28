// Reference solution: Shortest string containing both. Build the LCS table, then walk back from the
// corner: a matching pair is written once and both strings step back; otherwise write the character
// of the string whose step keeps the LCS (up on ties). Whatever is left of either string goes at the
// front. Every LCS character is shared and everything else appears once, so the length is
// n + m − LCS, the shortest possible. O(n · m) time and space.

public enum ShortestCombinedSupersequence {
    public static func shortest(_ first: String, _ second: String) -> String {
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
        var result: [Character] = []
        var i = n, j = m
        while i > 0 && j > 0 {
            if a[i - 1] == b[j - 1] {
                result.append(a[i - 1])
                i -= 1
                j -= 1
            } else if table[i - 1][j] >= table[i][j - 1] {
                result.append(a[i - 1])
                i -= 1
            } else {
                result.append(b[j - 1])
                j -= 1
            }
        }
        while i > 0 {
            result.append(a[i - 1])
            i -= 1
        }
        while j > 0 {
            result.append(b[j - 1])
            j -= 1
        }
        return String(result.reversed())
    }
}
