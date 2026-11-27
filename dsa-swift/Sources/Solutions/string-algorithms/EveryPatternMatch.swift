// Reference solution: Find every occurrence of a pattern. KMP: build the pattern's prefix function,
// then stream the text, keeping j = how many pattern characters match so far. On a mismatch j falls
// back to pi[j - 1] (the longest border of what matched) and the text pointer never moves back; after a
// full match j falls to pi[m - 1], so overlapping matches are found too. The input is ASCII, so bytes
// are characters and byte offsets are character offsets. O(n + m) time, O(m) extra space.

public enum EveryPatternMatch {
    public static func positions(of pattern: String, in text: String) -> [Int] {
        let p = Array(pattern.utf8)
        let t = Array(text.utf8)
        guard !p.isEmpty, p.count <= t.count else { return [] }

        var pi = [Int](repeating: 0, count: p.count)        // pi[i] = longest border of p[0...i]
        var k = 0
        for i in p.indices.dropFirst() {
            while k > 0 && p[i] != p[k] { k = pi[k - 1] }
            if p[i] == p[k] { k += 1 }
            pi[i] = k
        }

        var result: [Int] = []
        var j = 0
        for (i, c) in t.enumerated() {
            while j > 0 && c != p[j] { j = pi[j - 1] }
            if c == p[j] { j += 1 }
            if j == p.count {
                result.append(i - p.count + 1)
                j = pi[j - 1]
            }
        }
        return result
    }
}
