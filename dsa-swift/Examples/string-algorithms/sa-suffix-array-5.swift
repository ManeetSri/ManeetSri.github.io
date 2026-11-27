// Generated from src/dsa/content/lessons/string-algorithms/sa-suffix-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Kasai's algorithm: lcp[p] = the longest common prefix of the suffixes at sa[p - 1] and sa[p]
func lcpArray(_ s: [UInt8], _ sa: [Int]) -> [Int] {
    let n = s.count
    var rank = [Int](repeating: 0, count: n)        // rank[i] = where suffix i sits in sa
    for (p, start) in sa.enumerated() { rank[start] = p }
    var lcp = [Int](repeating: 0, count: n)
    var h = 0
    for i in 0..<n {                                // suffixes in text order, longest first
        if rank[i] == 0 {
            h = 0                                   // the smallest suffix has no neighbour before it
            continue
        }
        let j = sa[rank[i] - 1]                     // the suffix just before i in sorted order
        while i + h < n && j + h < n && s[i + h] == s[j + h] {
            h += 1
        }
        lcp[rank[i]] = h
        if h > 0 { h -= 1 }                         // suffix i + 1 keeps at least h - 1 of it
    }
    return lcp
}

let text = Array("banana".utf8)
let sa = text.indices.sorted { text[$0...].lexicographicallyPrecedes(text[$1...]) }
let lcp = lcpArray(text, sa)
for p in sa.indices {
    print(lcp[p], String(decoding: text[sa[p]...], as: UTF8.self))
}
