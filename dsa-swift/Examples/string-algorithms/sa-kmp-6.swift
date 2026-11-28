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

for word in ["abcabcabc", "abcabcab", "aaaa", "abcd", "abaaba"] {
    let s = Array(word.utf8)
    let period = s.count - prefixFunction(s).last!     // n minus the longest border
    if period < s.count && s.count % period == 0 {
        print(word, "period", period, "- a block of \(period) repeated \(s.count / period) times")
    } else {
        print(word, "period", period, "- no shorter block builds it")
    }
}
