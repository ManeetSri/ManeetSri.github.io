// Generated from src/dsa/content/lessons/sliding-window/sw-longest-no-repeat.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestUniqueRun(_ text: String) -> Int {
    let chars = Array(text)
    var seen = Set<Character>()
    var left = 0
    var best = 0
    for right in 0..<chars.count {
        while seen.contains(chars[right]) {
            seen.remove(chars[left])
            left += 1
        }
        seen.insert(chars[right])
        best = max(best, right - left + 1)
    }
    return best
}

print(longestUniqueRun("streets"))
print(longestUniqueRun("abcbcad"))
print(longestUniqueRun("aaaa"))
print(longestUniqueRun(""))
