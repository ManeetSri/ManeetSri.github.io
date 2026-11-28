// Generated from src/dsa/content/lessons/strings-basic/str-naive-matching.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func occurrences(of pattern: String, in text: String) -> [Int] {
    let t = Array(text)
    let p = Array(pattern)
    guard !p.isEmpty, p.count <= t.count else { return [] }
    var result: [Int] = []
    for start in 0...(t.count - p.count) {
        var matched = 0
        while matched < p.count && t[start + matched] == p[matched] {
            matched += 1
        }
        if matched == p.count {
            result.append(start)
        }
    }
    return result
}

print(occurrences(of: "abra", in: "abracadabra"))
print(occurrences(of: "aa", in: "aaaa"))
print(occurrences(of: "xyz", in: "abc"))
print(occurrences(of: "longer", in: "short"))
