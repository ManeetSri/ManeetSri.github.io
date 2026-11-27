// Generated from src/dsa/content/lessons/strings-basic/str-naive-matching.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func comparisons(pattern: String, text: String) -> Int {
    let t = Array(text.utf8)
    let p = Array(pattern.utf8)
    var count = 0
    for start in 0...(t.count - p.count) {
        var matched = 0
        while matched < p.count {
            count += 1
            if t[start + matched] != p[matched] {
                break
            }
            matched += 1
        }
    }
    return count
}

let english = String(repeating: "the quick brown fox jumps over the lazy dog ", count: 25)
print(english.utf8.count, comparisons(pattern: "lazy cat", text: english))

let worst = String(repeating: "a", count: 1_100)
let nearlyThere = String(repeating: "a", count: 99) + "b"
print(worst.utf8.count, comparisons(pattern: nearlyThere, text: worst))
