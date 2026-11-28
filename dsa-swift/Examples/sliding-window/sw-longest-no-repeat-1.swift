// Generated from src/dsa/content/lessons/sliding-window/sw-longest-no-repeat.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestBrute(_ text: String) -> Int {
    let chars = Array(text)
    var best = 0
    for start in chars.indices {
        var seen = Set<Character>()
        for end in start..<chars.count {
            if seen.contains(chars[end]) {
                break
            }
            seen.insert(chars[end])
            best = max(best, end - start + 1)
        }
    }
    return best
}

print(longestBrute("streets"))
print(longestBrute("abcbcad"))
