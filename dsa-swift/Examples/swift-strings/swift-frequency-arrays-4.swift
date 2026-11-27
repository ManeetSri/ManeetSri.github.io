// Generated from src/dsa/content/lessons/swift-strings/swift-frequency-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func letterCounts(_ text: String) -> [Int] {
    var counts = [Int](repeating: 0, count: 26)
    for byte in text.utf8 {
        counts[Int(byte - 97)] += 1
    }
    return counts
}

print(letterCounts("stop") == letterCounts("post"))
print(letterCounts("abc") == letterCounts("abd"))
