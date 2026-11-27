// Generated from src/dsa/content/lessons/dp-strings/dps-wildcard-regex.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Does the whole of `text` match `pattern`? '?' matches any one character, '*' any run (even empty).
func wildcardMatch(_ text: String, _ pattern: String) -> Bool {
    let t = Array(text), p = Array(pattern)
    var match = Array(repeating: Array(repeating: false, count: p.count + 1), count: t.count + 1)
    for i in 0...t.count {
        for j in 0...p.count {
            if j == 0 {
                match[i][j] = i == 0                            // the empty pattern matches only ""
            } else if p[j - 1] == "*" {
                match[i][j] = match[i][j - 1]                   // the star matches nothing
                    || (i > 0 && match[i - 1][j])               // or it swallows t[i - 1] too
            } else if i > 0 && (p[j - 1] == "?" || p[j - 1] == t[i - 1]) {
                match[i][j] = match[i - 1][j - 1]               // one character for one character
            }
        }
    }
    return match[t.count][p.count]
}

let cases = [("report.swift", "*.swift"), ("report.swift", "*.sw?ft"), ("report.swift", "r*t"),
             ("report.swift", "*.md"), ("", "*"), ("", "?"), ("abc", "a**c"), ("abc", "")]
for (text, pattern) in cases {
    print("\"\(text)\" ~ \"\(pattern)\":", wildcardMatch(text, pattern))
}
