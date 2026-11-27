// Generated from src/dsa/content/lessons/swift-strings/swift-frequency-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func canBuild(_ note: String, from magazine: String) -> Bool {
    var available = [Int](repeating: 0, count: 26)
    for byte in magazine.utf8 {
        available[Int(byte - 97)] += 1
    }
    for byte in note.utf8 {
        let slot = Int(byte - 97)
        available[slot] -= 1
        if available[slot] < 0 {
            return false
        }
    }
    return true
}

print(canBuild("aab", from: "baa"))
print(canBuild("aa", from: "ab"))
