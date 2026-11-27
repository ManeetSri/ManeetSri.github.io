// Reference solution: Wildcard pattern matching. match[i][j] says whether the first i characters of
// the text match the first j of the pattern. The empty pattern matches only the empty text, and the
// empty text matches only a run of stars. A star either matches nothing (match[i][j - 1]) or takes one
// more character and stays available (match[i - 1][j]); '?' or an equal character consumes one of
// each (match[i - 1][j - 1]). Two rows are enough. O(n · m) time, O(m) space.

public enum WildcardPatternMatcher {
    public static func matches(_ text: String, pattern: String) -> Bool {
        let t = Array(text), p = Array(pattern)
        var previous = Array(repeating: false, count: p.count + 1)       // row i - 1
        var current = previous
        for i in 0...t.count {
            for j in 0...p.count {
                if j == 0 {
                    current[j] = i == 0
                } else if p[j - 1] == "*" {
                    current[j] = current[j - 1] || (i > 0 && previous[j])
                } else if i > 0 && (p[j - 1] == "?" || p[j - 1] == t[i - 1]) {
                    current[j] = previous[j - 1]
                } else {
                    current[j] = false
                }
            }
            swap(&previous, &current)
        }
        return previous[p.count]
    }
}
