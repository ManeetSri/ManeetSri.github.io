// Generated from src/dsa/content/lessons/string-algorithms/sa-kmp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func prefixFunction<T: Equatable>(_ s: [T]) -> [Int] {
    var pi = [Int](repeating: 0, count: s.count)
    var k = 0
    for i in s.indices.dropFirst() {
        while k > 0 && s[i] != s[k] { k = pi[k - 1] }
        if s[i] == s[k] { k += 1 }
        pi[i] = k
    }
    return pi
}

// KMP: every start of pattern in text, in O(n + m)
func kmpSearch(_ pattern: [UInt8], in text: [UInt8], trace: Bool = false) -> [Int] {
    guard !pattern.isEmpty else { return [] }
    let pi = prefixFunction(pattern)
    var result: [Int] = []
    var j = 0                                       // how many pattern characters match so far
    for (i, c) in text.enumerated() {
        let before = j
        while j > 0 && c != pattern[j] {
            j = pi[j - 1]                           // shift the pattern; the text pointer stays
        }
        if c == pattern[j] {
            j += 1
        }
        if trace {
            print("i = \(i)  \(Character(UnicodeScalar(c)))  j: \(before) -> \(j)")
        }
        if j == pattern.count {
            result.append(i - j + 1)
            j = pi[j - 1]                           // matches can overlap, so keep the border
        }
    }
    return result
}

print(kmpSearch(Array("abacabab".utf8), in: Array("abacabacabab".utf8), trace: true))
print(kmpSearch(Array("aa".utf8), in: Array("aaaa".utf8)))
print(kmpSearch(Array("abra".utf8), in: Array("abracadabra".utf8)))
