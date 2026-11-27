// Generated from src/dsa/content/lessons/dp-strings/dps-wildcard-regex.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Does the whole of `text` match `pattern`? '.' matches any one character, and 'x*' matches
/// zero or more copies of x (x is a letter or '.'). A '*' never starts the pattern.
func regexMatch(_ text: String, _ pattern: String) -> Bool {
    let t = Array(text), p = Array(pattern)
    var match = Array(repeating: Array(repeating: false, count: p.count + 1), count: t.count + 1)
    for i in 0...t.count {
        for j in 0...p.count {
            if j == 0 {
                match[i][j] = i == 0                             // the empty pattern matches only ""
            } else if p[j - 1] == "*" {
                let none = match[i][j - 2]                       // use x* zero times
                let oneMore = i > 0 && (p[j - 2] == "." || p[j - 2] == t[i - 1]) && match[i - 1][j]
                match[i][j] = none || oneMore
            } else if i > 0 && (p[j - 1] == "." || p[j - 1] == t[i - 1]) {
                match[i][j] = match[i - 1][j - 1]
            }
        }
    }
    return match[t.count][p.count]
}

let cases = [("colour", "colou*r"), ("color", "colou*r"), ("aab", "c*a*b"), ("swift", "s.*t"),
             ("", "a*b*"), ("ab", ".*c"), ("aaa", "a*a"), ("a", ".*..")]
for (text, pattern) in cases {
    print("\"\(text)\" ~ \"\(pattern)\":", regexMatch(text, pattern))
}
