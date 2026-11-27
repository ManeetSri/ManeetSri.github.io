// Generated from src/dsa/content/lessons/string-algorithms/sa-kmp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Matching with one prefix function: pattern, a separator, then the text
func prefixFunction(_ s: [Int]) -> [Int] {
    var pi = [Int](repeating: 0, count: s.count)
    var k = 0
    for i in s.indices.dropFirst() {
        while k > 0 && s[i] != s[k] { k = pi[k - 1] }
        if s[i] == s[k] { k += 1 }
        pi[i] = k
    }
    return pi
}

let pattern = "ana", text = "bananas"
let m = pattern.utf8.count
let combined = pattern.utf8.map { Int($0) } + [-1] + text.utf8.map { Int($0) }   // -1 is no byte
let pi = prefixFunction(combined)
var starts: [Int] = []
for i in combined.indices where pi[i] == m {
    starts.append(i - 2 * m)                           // i - m - 1 is the end in text, minus m - 1
}
print(pi)
print(starts)
