// Generated from src/dsa/content/lessons/string-algorithms/sa-suffix-array.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// O(n log n): the same doubling, with each round's sort done by counting sort in O(n)
func suffixArray(_ text: [UInt8]) -> [Int] {
    let s = text.map { Int($0) + 1 } + [0]          // a sentinel 0, smaller than every character
    let n = s.count
    var sa = [Int](repeating: 0, count: n)
    var rank = [Int](repeating: 0, count: n)
    var count = [Int](repeating: 0, count: max(257, n))
    for c in s { count[c] += 1 }                    // round 0: counting sort by one character
    for c in count.indices.dropFirst() { count[c] += count[c - 1] }
    for i in stride(from: n - 1, through: 0, by: -1) {
        count[s[i]] -= 1
        sa[count[s[i]]] = i
    }
    var classes = 1
    for p in 1..<n {
        if s[sa[p]] != s[sa[p - 1]] { classes += 1 }
        rank[sa[p]] = classes - 1
    }
    var shifted = [Int](repeating: 0, count: n)
    var newRank = [Int](repeating: 0, count: n)
    var k = 1
    while classes < n {
        // Already sorted by the second half: start each suffix k places earlier (wrapping round)
        for p in 0..<n { shifted[p] = (sa[p] - k + n) % n }
        // A stable counting sort by the first half's rank
        count = [Int](repeating: 0, count: classes)
        for i in shifted { count[rank[i]] += 1 }
        for c in count.indices.dropFirst() { count[c] += count[c - 1] }
        for i in shifted.reversed() {
            count[rank[i]] -= 1
            sa[count[rank[i]]] = i
        }
        newRank[sa[0]] = 0
        classes = 1
        for p in 1..<n {
            let current = (rank[sa[p]], rank[(sa[p] + k) % n])
            let previous = (rank[sa[p - 1]], rank[(sa[p - 1] + k) % n])
            if current != previous { classes += 1 }
            newRank[sa[p]] = classes - 1
        }
        swap(&rank, &newRank)
        k *= 2
    }
    return Array(sa.dropFirst())                    // the sentinel's suffix always sorts first
}

// Check it against plain sorting on many small strings, the same every run
var seed = 5
func nextNumber(below limit: Int) -> Int {
    seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
    return (seed >> 16) % limit
}
var agree = 0
for _ in 0..<300 {
    let text = (0..<nextNumber(below: 30)).map { _ in UInt8(97 + nextNumber(below: 3)) }
    let slow = text.indices.sorted { text[$0...].lexicographicallyPrecedes(text[$1...]) }
    if suffixArray(text) == slow { agree += 1 }
}
print("agree on \(agree) of 300 random strings")
print(suffixArray(Array("banana".utf8)), suffixArray([]), suffixArray(Array("a".utf8)))
let long = (0..<100_000).map { _ in UInt8(97 + nextNumber(below: 2)) }
let sa = suffixArray(long)
let ordered = sa.indices.dropFirst().allSatisfy { long[sa[$0 - 1]...].lexicographicallyPrecedes(long[sa[$0]...]) }
print("100,000 characters:", sa.count, "suffixes, every neighbouring pair in order:", ordered)
