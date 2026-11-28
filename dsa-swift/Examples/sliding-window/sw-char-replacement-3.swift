// Generated from src/dsa/content/lessons/sliding-window/sw-char-replacement.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestRun(_ text: String, changes k: Int) -> Int {
    let bytes = Array(text.utf8)
    let a = UInt8(ascii: "A")
    var counts = [Int](repeating: 0, count: 26)
    var left = 0
    var best = 0
    for right in 0..<bytes.count {
        counts[Int(bytes[right] - a)] += 1
        while (right - left + 1) - counts.max()! > k {
            counts[Int(bytes[left] - a)] -= 1
            left += 1
        }
        best = max(best, right - left + 1)
    }
    return best
}

print(longestRun("BAAAB", changes: 1))
print(longestRun("KAYAK", changes: 2))
