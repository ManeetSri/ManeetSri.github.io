// Generated from src/dsa/content/lessons/string-algorithms/sa-suffix-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Prefix doubling: sort by the first 1, 2, 4, 8, … characters, using the ranks from the round before
func suffixArray(_ s: [UInt8], trace: Bool = false) -> [Int] {
    let n = s.count
    guard n > 1 else { return Array(0..<n) }
    var sa = Array(0..<n)
    var rank = s.map { Int($0) }                // round 0: rank by the first character
    var newRank = [Int](repeating: 0, count: n)
    var k = 1
    while true {
        // Each suffix's first 2k characters = its first k, then the first k of the suffix k later
        func key(_ i: Int) -> (Int, Int) { (rank[i], i + k < n ? rank[i + k] : -1) }
        sa.sort { key($0) < key($1) }
        newRank[sa[0]] = 0
        for p in 1..<n {
            newRank[sa[p]] = newRank[sa[p - 1]] + (key(sa[p - 1]) < key(sa[p]) ? 1 : 0)
        }
        rank = newRank
        if trace { print("first \(2 * k) characters, ranks:", rank) }
        if rank[sa[n - 1]] == n - 1 { break }   // every rank different: fully sorted
        k *= 2
    }
    return sa
}

print(suffixArray(Array("banana".utf8), trace: true))
