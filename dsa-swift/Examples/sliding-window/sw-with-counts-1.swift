// Generated from src/dsa/content/lessons/sliding-window/sw-with-counts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func containsAnagramBrute(_ pattern: String, in text: String) -> Bool {
    let p = Array(pattern).sorted()
    let t = Array(text)
    guard p.count <= t.count else { return false }
    for start in 0...(t.count - p.count) {
        if t[start..<start + p.count].sorted() == p {
            return true
        }
    }
    return false
}

print(containsAnagramBrute("tops", in: "whatspot"))
print(containsAnagramBrute("tops", in: "stoop"))
