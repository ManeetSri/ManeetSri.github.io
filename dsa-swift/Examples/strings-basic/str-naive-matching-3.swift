// Generated from src/dsa/content/lessons/strings-basic/str-naive-matching.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countNonOverlapping(_ pattern: String, in text: String) -> Int {
    let t = Array(text)
    let p = Array(pattern)
    guard !p.isEmpty else { return 0 }
    var count = 0
    var start = 0
    while start + p.count <= t.count {
        if t[start..<start + p.count].elementsEqual(p) {
            count += 1
            start += p.count            // jump past the match
        } else {
            start += 1
        }
    }
    return count
}

print(countNonOverlapping("aa", in: "aaaa"))
print(countNonOverlapping("aba", in: "abababa"))
