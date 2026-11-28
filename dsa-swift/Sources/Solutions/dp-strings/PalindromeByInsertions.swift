// Reference solution: Fewest insertions to make a palindrome. best[i][j] is the longest palindromic
// subsequence inside text[i...j]: matching ends wrap the inside (+2), otherwise drop one end or the
// other. Rows are filled from the bottom up, so best[i + 1] is ready when row i needs it. The letters
// of that subsequence can stay as the palindrome's skeleton, and every other letter needs one inserted
// partner, so the fewest insertions are n − LPS. O(n²) time and space.

public enum PalindromeByInsertions {
    public static func longestPalindromicSubsequence(_ text: String) -> Int {
        let s = Array(text)
        let n = s.count
        if n == 0 { return 0 }
        var best = Array(repeating: Array(repeating: 0, count: n), count: n)
        for i in stride(from: n - 1, through: 0, by: -1) {
            best[i][i] = 1
            for j in stride(from: i + 1, to: n, by: 1) {
                if s[i] == s[j] {
                    best[i][j] = best[i + 1][j - 1] + 2
                } else {
                    best[i][j] = max(best[i + 1][j], best[i][j - 1])
                }
            }
        }
        return best[0][n - 1]
    }

    public static func fewestInsertions(_ text: String) -> Int {
        text.count - longestPalindromicSubsequence(text)
    }
}
