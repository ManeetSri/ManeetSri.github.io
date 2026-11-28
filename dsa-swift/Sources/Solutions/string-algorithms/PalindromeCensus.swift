// Reference solution: Count palindromic substrings in a long text. Manacher's algorithm on the text
// with a separator (-1) around every letter, so every palindrome is odd and centred on a letter or a
// separator, and the radius rad[i] equals the palindrome's length in the original text. The mirror
// trick starts each radius at min(rad[mirror], right - i) and only compares beyond the furthest right
// edge seen so far. A centre with radius r holds (r + 1) / 2 palindromes (lengths r, r - 2, …).
// O(n) time and space.

public enum PalindromeCensus {
    public static func count(in text: String) -> Int {
        let s = Array(text.utf8)
        var t = [Int](repeating: -1, count: 2 * s.count + 1)
        for (k, c) in s.enumerated() {
            t[2 * k + 1] = Int(c)
        }
        let n = t.count
        var rad = [Int](repeating: 0, count: n)
        var centre = 0, right = 0
        var total = 0
        for i in 0..<n {
            if i < right {
                rad[i] = min(rad[2 * centre - i], right - i)
            }
            while i - rad[i] - 1 >= 0 && i + rad[i] + 1 < n && t[i - rad[i] - 1] == t[i + rad[i] + 1] {
                rad[i] += 1
            }
            if i + rad[i] > right {
                centre = i
                right = i + rad[i]
            }
            total += (rad[i] + 1) / 2
        }
        return total
    }
}
