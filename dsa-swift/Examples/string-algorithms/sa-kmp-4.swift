// Generated from src/dsa/content/lessons/string-algorithms/sa-kmp.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

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

// Character comparisons made by each algorithm: counted, not timed
func naiveComparisons(_ p: [UInt8], _ t: [UInt8]) -> Int {
    var count = 0
    for start in 0...(t.count - p.count) {
        for k in p.indices {
            count += 1
            if t[start + k] != p[k] { break }
        }
    }
    return count
}

func kmpComparisons(_ p: [UInt8], _ t: [UInt8]) -> Int {
    let pi = prefixFunction(p)
    var count = 0
    var j = 0
    for c in t {
        while j > 0 && c != p[j] {
            count += 1                              // a failed comparison, then a fallback
            j = pi[j - 1]
        }
        count += 1                                  // the comparison that ends the loop
        if c == p[j] { j += 1 }
        if j == p.count { j = pi[j - 1] }
    }
    return count
}

let text = Array(String(repeating: "a", count: 10_000).utf8)
let pattern = Array((String(repeating: "a", count: 99) + "b").utf8)
print("naive:", naiveComparisons(pattern, text))
print("KMP:  ", kmpComparisons(pattern, text))

let english = Array(String(repeating: "the quick brown fox jumps over the lazy dog ", count: 230).utf8)
let word = Array("lazy cat".utf8)
print("English, naive:", naiveComparisons(word, english), "KMP:", kmpComparisons(word, english), "n:", english.count)
