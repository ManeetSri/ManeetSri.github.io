// Generated from src/dsa/content/lessons/string-algorithms/sa-kmp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The definition, checked the slow way: the longest proper prefix of s[0...i] that's also a suffix
func slowPrefixFunction(_ s: [UInt8]) -> [Int] {
    var pi = [Int](repeating: 0, count: s.count)
    for i in s.indices {
        for length in stride(from: i, to: 0, by: -1) {          // longest proper border first
            if s[0..<length].elementsEqual(s[(i + 1 - length)...i]) {
                pi[i] = length
                break
            }
        }
    }
    return pi
}

for word in ["abacabab", "aabaaab", "aaaa", "abcd"] {
    print(word, slowPrefixFunction(Array(word.utf8)))
}
