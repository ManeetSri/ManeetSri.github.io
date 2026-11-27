// Generated from src/dsa/content/lessons/sliding-window/sw-char-replacement.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestRun(_ text: String, changes k: Int) -> Int {
    let bytes = Array(text.utf8)
    var best = 0
    for target in UInt8(ascii: "A")...UInt8(ascii: "Z") {
        var left = 0
        var others = 0                 // letters in the window that would need changing
        for right in 0..<bytes.count {
            if bytes[right] != target {
                others += 1
            }
            while others > k {
                if bytes[left] != target {
                    others -= 1
                }
                left += 1
            }
            best = max(best, right - left + 1)
        }
    }
    return best
}

print(longestRun("QQXQQYQQ", changes: 1))
print(longestRun("QQXQQYQQ", changes: 2))
print(longestRun("ABCDE", changes: 1))
