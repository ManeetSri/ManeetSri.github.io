// Generated from src/dsa/content/lessons/dp-strings/dps-wildcard-regex.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0

/// Plain recursion: does t[i...] match p[j...]?
func matches(_ t: [Character], _ p: [Character], _ i: Int, _ j: Int) -> Bool {
    calls += 1
    if j == p.count {
        return i == t.count                              // pattern used up: text must be too
    }
    if p[j] == "*" {
        return matches(t, p, i, j + 1)                   // the star matches nothing
            || (i < t.count && matches(t, p, i + 1, j))  // or one more character
    }
    return i < t.count && (p[j] == "?" || p[j] == t[i]) && matches(t, p, i + 1, j + 1)
}

for length in [10, 20, 40] {
    calls = 0
    let text = Array(String(repeating: "a", count: length))
    let result = matches(text, Array("*a*a*a*b"), 0, 0)
    print(length, result, calls)
}
