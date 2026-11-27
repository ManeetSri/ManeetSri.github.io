// Generated from src/dsa/content/lessons/string-algorithms/sa-kmp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Every border of s, longest first: π[n - 1], then π of that, and so on
func prefixFunction(_ s: [UInt8]) -> [Int] {
    var pi = [Int](repeating: 0, count: s.count)
    var k = 0
    for i in s.indices.dropFirst() {
        while k > 0 && s[i] != s[k] { k = pi[k - 1] }
        if s[i] == s[k] { k += 1 }
        pi[i] = k
    }
    return pi
}

let word = Array("abacaba".utf8)
let pi = prefixFunction(word)
var border = pi[word.count - 1]
while border > 0 {
    print(border, String(decoding: word[0..<border], as: UTF8.self), "period", word.count - border)
    border = pi[border - 1]
}
