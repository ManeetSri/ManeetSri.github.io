// Generated from src/dsa/content/lessons/string-algorithms/sa-boyer-moore.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Character comparisons for naive matching, KMP and Boyer–Moore's bad-character rule: counted, not timed
func naive(_ p: [UInt8], _ t: [UInt8]) -> Int {
    var count = 0
    for s in 0...(t.count - p.count) {
        for k in p.indices {
            count += 1
            if t[s + k] != p[k] { break }
        }
    }
    return count
}

func kmp(_ p: [UInt8], _ t: [UInt8]) -> Int {
    var pi = [Int](repeating: 0, count: p.count)
    var k = 0
    for i in p.indices.dropFirst() {
        while k > 0 && p[i] != p[k] { k = pi[k - 1] }
        if p[i] == p[k] { k += 1 }
        pi[i] = k
    }
    var count = 0, j = 0
    for c in t {
        while j > 0 && c != p[j] { count += 1; j = pi[j - 1] }
        count += 1
        if c == p[j] { j += 1 }
        if j == p.count { j = pi[j - 1] }
    }
    return count
}

func badCharacter(_ p: [UInt8], _ t: [UInt8]) -> Int {
    let m = p.count, n = t.count
    var last = [Int](repeating: -1, count: 256)
    for (k, c) in p.enumerated() { last[Int(c)] = k }
    var count = 0, s = 0
    while s <= n - m {
        var j = m - 1
        while j >= 0 {
            count += 1
            if p[j] != t[s + j] { break }
            j -= 1
        }
        if j < 0 {
            s += s + m < n ? m - last[Int(t[s + m])] : 1
        } else {
            s += max(1, j - last[Int(t[s + j])])
        }
    }
    return count
}

let text = Array(String(repeating: "the quick brown fox jumps over the lazy dog ", count: 230).utf8)
print("n =", text.count)
for word in ["lazy", "lazy cat", "the lazy brown cat", "a fox that jumps over cats"] {
    let p = Array(word.utf8)
    print("\"\(word)\": naive \(naive(p, text)), KMP \(kmp(p, text)), Boyer–Moore \(badCharacter(p, text))")
}
let aaa = Array(String(repeating: "a", count: 10_000).utf8)
let bad = Array(("b" + String(repeating: "a", count: 99)).utf8)
print("a's with \"baaa…a\": naive \(naive(bad, aaa)), KMP \(kmp(bad, aaa)), Boyer–Moore \(badCharacter(bad, aaa))")
