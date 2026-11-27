// Generated from src/dsa/content/lessons/swift-library/lib-swift-collections.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The idea behind BitSet: one bit per possible member, 64 members to a UInt64 word
struct TinyBitSet {
    private var words: [UInt64] = []

    mutating func insert(_ member: Int) {
        let (word, bit) = (member / 64, member % 64)
        while words.count <= word {
            words.append(0)
        }
        words[word] |= 1 << UInt64(bit)
    }

    func contains(_ member: Int) -> Bool {
        let (word, bit) = (member / 64, member % 64)
        return word < words.count && words[word] & (1 << UInt64(bit)) != 0
    }

    func union(_ other: TinyBitSet) -> TinyBitSet {
        var result = TinyBitSet()
        result.words = (0..<max(words.count, other.words.count)).map { index in
            (index < words.count ? words[index] : 0) | (index < other.words.count ? other.words[index] : 0)
        }
        return result
    }

    var members: [Int] {
        var result: [Int] = []
        for (index, word) in words.enumerated() {
            for bit in 0..<64 where word & (1 << UInt64(bit)) != 0 {
                result.append(index * 64 + bit)
            }
        }
        return result
    }
}

var visited = TinyBitSet()
for node in [130, 3, 64, 7, 3] {
    visited.insert(node)
}
print(visited.members)
print(visited.contains(64), visited.contains(65))

var other = TinyBitSet()
other.insert(5)
other.insert(130)
print(visited.union(other).members)
