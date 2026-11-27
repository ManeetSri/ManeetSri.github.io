// Reference solution: Repeating blocks of every prefix. For the prefix of length L, the longest border
// is pi[L - 1], so its smallest period is p = L - pi[L - 1]. The prefix is a whole number of copies of
// its first p characters exactly when p divides L; otherwise no block shorter than L builds it (any
// block length d that works is a period, and the smallest period p would then divide d and so L).
// One prefix function gives every answer. O(n) time and space.

public enum PrefixRepeatBlocks {
    public static func blockLengths(of text: String) -> [Int] {
        let s = Array(text.utf8)
        var pi = [Int](repeating: 0, count: s.count)
        var k = 0
        for i in s.indices.dropFirst() {
            while k > 0 && s[i] != s[k] { k = pi[k - 1] }
            if s[i] == s[k] { k += 1 }
            pi[i] = k
        }
        return s.indices.map { i in
            let length = i + 1
            let period = length - pi[i]
            return length % period == 0 ? period : length
        }
    }
}
