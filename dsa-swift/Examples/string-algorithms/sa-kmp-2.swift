// Generated from src/dsa/content/lessons/string-algorithms/sa-kmp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func prefixFunction<T: Equatable>(_ s: [T]) -> [Int] {
    var pi = [Int](repeating: 0, count: s.count)
    var k = 0                                   // length of the border being extended
    for i in s.indices.dropFirst() {
        while k > 0 && s[i] != s[k] {
            k = pi[k - 1]                       // fall back to the next shorter border
        }
        if s[i] == s[k] {
            k += 1                              // the border grows by one character
        }
        pi[i] = k
    }
    return pi
}

print(prefixFunction(Array("abacabab".utf8)))
print(prefixFunction(Array("aabaaab".utf8)))
print(prefixFunction(Array("")))
print(prefixFunction(Array("añaña")))           // Characters work too: the function is generic
