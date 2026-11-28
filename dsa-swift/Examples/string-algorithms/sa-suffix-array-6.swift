// Generated from src/dsa/content/lessons/string-algorithms/sa-suffix-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func suffixArray(_ s: [UInt8]) -> [Int] {
    let n = s.count
    guard n > 1 else { return Array(0..<n) }
    var sa = Array(0..<n)
    var rank = s.map { Int($0) }
    var newRank = [Int](repeating: 0, count: n)
    var k = 1
    while true {
        func key(_ i: Int) -> (Int, Int) { (rank[i], i + k < n ? rank[i + k] : -1) }
        sa.sort { key($0) < key($1) }
        newRank[sa[0]] = 0
        for p in 1..<n { newRank[sa[p]] = newRank[sa[p - 1]] + (key(sa[p - 1]) < key(sa[p]) ? 1 : 0) }
        rank = newRank
        if rank[sa[n - 1]] == n - 1 { break }
        k *= 2
    }
    return sa
}

func lcpArray(_ s: [UInt8], _ sa: [Int]) -> [Int] {
    let n = s.count
    var rank = [Int](repeating: 0, count: n)
    for (p, start) in sa.enumerated() { rank[start] = p }
    var lcp = [Int](repeating: 0, count: n)
    var h = 0
    for i in 0..<n {
        if rank[i] == 0 { h = 0; continue }
        let j = sa[rank[i] - 1]
        while i + h < n && j + h < n && s[i + h] == s[j + h] { h += 1 }
        lcp[rank[i]] = h
        if h > 0 { h -= 1 }
    }
    return lcp
}

for word in ["banana", "abab", "aaaa", "mississippi"] {
    let s = Array(word.utf8)
    let sa = suffixArray(s)
    let lcp = lcpArray(s, sa)
    let n = s.count
    let distinct = n * (n + 1) / 2 - lcp.reduce(0, +)
    let best = lcp.indices.max { lcp[$0] < lcp[$1] }!        // the first largest LCP
    let repeated = String(decoding: s[sa[best]..<(sa[best] + lcp[best])], as: UTF8.self)
    var brute = Set<ArraySlice<UInt8>>()                      // check: every substring in a set
    for a in 0..<n { for b in (a + 1)...n { brute.insert(s[a..<b]) } }
    print(word, "distinct:", distinct, "(brute force \(brute.count))", "longest repeat: \"\(repeated)\"")
}
