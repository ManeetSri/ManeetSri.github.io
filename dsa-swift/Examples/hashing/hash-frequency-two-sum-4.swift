// Generated from src/dsa/content/lessons/hashing/hash-frequency-two-sum.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func hasRepeat(in values: [Int], within distance: Int) -> Bool {
    var lastSeen: [Int: Int] = [:]
    for (index, value) in values.enumerated() {
        if let previous = lastSeen[value], index - previous <= distance {
            return true
        }
        lastSeen[value] = index              // overwrite: the newest copy is the closest
    }
    return false
}

print(hasRepeat(in: [4, 1, 7, 4], within: 3))
print(hasRepeat(in: [4, 1, 7, 4], within: 2))
