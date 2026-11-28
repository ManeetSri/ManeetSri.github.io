// Reference solution: Regex-lite matching. match[i][j] says whether the first i characters of the text
// match the first j of the pattern. "x*" at p[j - 2], p[j - 1] either matches nothing
// (match[i][j - 2]) or, when x matches t[i - 1], takes that character and stays available
// (match[i - 1][j]). A letter or '.' consumes one character of each. The empty text row only lets
// "x*" pairs vanish. O(n · m) time and space.

public enum RegexLiteMatcher {
    public static func matches(_ text: String, pattern: String) -> Bool {
        let t = Array(text), p = Array(pattern)
        var match = Array(repeating: Array(repeating: false, count: p.count + 1), count: t.count + 1)
        for i in 0...t.count {
            for j in 0...p.count {
                if j == 0 {
                    match[i][j] = i == 0
                } else if p[j - 1] == "*" {
                    let none = j >= 2 && match[i][j - 2]
                    let oneMore = j >= 2 && i > 0 && (p[j - 2] == "." || p[j - 2] == t[i - 1]) && match[i - 1][j]
                    match[i][j] = none || oneMore
                } else if i > 0 && (p[j - 1] == "." || p[j - 1] == t[i - 1]) {
                    match[i][j] = match[i - 1][j - 1]
                }
            }
        }
        return match[t.count][p.count]
    }
}
