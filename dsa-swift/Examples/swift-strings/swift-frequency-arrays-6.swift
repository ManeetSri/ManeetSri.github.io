// Generated from src/dsa/content/lessons/swift-strings/swift-frequency-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstUniqueIndex(_ text: String) -> Int? {
    let bytes = Array(text.utf8)
    var counts = [Int](repeating: 0, count: 26)
    for byte in bytes {
        counts[Int(byte - 97)] += 1
    }
    for (i, byte) in bytes.enumerated() where counts[Int(byte - 97)] == 1 {
        return i
    }
    return nil
}

print(firstUniqueIndex("swiss") ?? -1)
print(firstUniqueIndex("level") ?? -1)
print(firstUniqueIndex("aabb") ?? -1)
