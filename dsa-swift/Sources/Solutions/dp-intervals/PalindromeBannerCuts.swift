// Reference solution: Cut a banner into palindromes. First a table isPal[i][j] of which pieces are
// palindromes, filled from the bottom row up because each cell needs the one diagonally inside it. Then
// cuts[j], the fewest cuts for the first j + 1 letters, comes from choosing where the last palindromic
// piece starts: 0 if the whole prefix is a palindrome, else 1 + cuts[i - 1] for the best start i.
// O(n²) time and space.

public enum PalindromeBannerCuts {
    public static func fewestCuts(_ banner: String) -> Int {
        let s = Array(banner)
        let n = s.count
        guard n > 1 else { return 0 }
        var isPal = Array(repeating: Array(repeating: false, count: n), count: n)
        for i in stride(from: n - 1, through: 0, by: -1) {
            for j in i..<n {
                isPal[i][j] = s[i] == s[j] && (j - i < 2 || isPal[i + 1][j - 1])
            }
        }
        var cuts = Array(repeating: 0, count: n)
        for j in 0..<n where !isPal[0][j] {
            var fewest = j                                  // a cut before every letter but the first
            for i in 1...j where isPal[i][j] {
                fewest = min(fewest, cuts[i - 1] + 1)
            }
            cuts[j] = fewest
        }
        return cuts[n - 1]
    }
}
