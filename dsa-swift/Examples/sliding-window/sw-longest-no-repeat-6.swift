// Generated from src/dsa/content/lessons/sliding-window/sw-longest-no-repeat.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestUniqueRunASCII(_ text: String) -> Int {
    let bytes = Array(text.utf8)
    var lastSeen = [Int](repeating: -1, count: 128)   // -1 means "not seen yet"
    var left = 0
    var best = 0
    for right in 0..<bytes.count {
        let code = Int(bytes[right])
        if lastSeen[code] >= left {
            left = lastSeen[code] + 1
        }
        lastSeen[code] = right
        best = max(best, right - left + 1)
    }
    return best
}

print(longestUniqueRunASCII("mississippi"))
print(longestUniqueRunASCII("a b c a"))
