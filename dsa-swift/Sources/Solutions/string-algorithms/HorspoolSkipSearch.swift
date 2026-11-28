// Reference solution: Skip-ahead text search. Horspool's table gives each byte the distance from its
// last occurrence in pattern[0..<(m - 1)] to the pattern's end (m if absent), so every skip is at least 1.
// Each alignment is checked from the right, then the search moves by the skip for the text byte under the
// pattern's last position. O(n · m) worst case, about n / m alignments on ordinary text.

public enum HorspoolSkipSearch {
    public static func search(_ pattern: String, in text: String) -> (positions: [Int], alignments: Int) {
        let p = Array(pattern.utf8)
        let t = Array(text.utf8)
        let m = p.count
        let n = t.count
        guard m > 0, m <= n else { return ([], 0) }
        var skip = [Int](repeating: m, count: 256)
        for k in 0..<(m - 1) {                    // leave out the last character, or its skip is 0
            skip[Int(p[k])] = m - 1 - k
        }
        var positions: [Int] = []
        var alignments = 0
        var s = 0
        while s <= n - m {
            alignments += 1
            var j = m - 1
            while j >= 0 && p[j] == t[s + j] {
                j -= 1
            }
            if j < 0 {
                positions.append(s)
            }
            s += skip[Int(t[s + m - 1])]
        }
        return (positions, alignments)
    }
}
