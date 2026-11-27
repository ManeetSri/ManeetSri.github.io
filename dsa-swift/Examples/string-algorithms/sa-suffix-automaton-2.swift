// Generated from src/dsa/content/lessons/string-algorithms/sa-suffix-automaton.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct SuffixAutomaton {
    var len = [0], link = [-1]
    var next: [[UInt8: Int]] = [[:]]
    var last = 0

    mutating func extend(_ c: UInt8) {
        let cur = len.count
        len.append(len[last] + 1); link.append(0); next.append([:])
        var p = last
        while p != -1 && next[p][c] == nil { next[p][c] = cur; p = link[p] }
        if p != -1 {
            let q = next[p][c]!
            if len[p] + 1 == len[q] {
                link[cur] = q
            } else {
                let clone = len.count
                len.append(len[p] + 1); link.append(link[q]); next.append(next[q])
                while p != -1 && next[p][c] == q { next[p][c] = clone; p = link[p] }
                link[q] = clone
                link[cur] = clone
            }
        }
        last = cur
    }

    // Each state holds the lengths len[link] + 1 ... len: that many distinct substrings
    var distinctSubstrings: Int {
        len.indices.dropFirst().reduce(0) { $0 + len[$1] - len[link[$1]] }
    }
}

for word in ["abb", "banana", "aaaa", "mississippi"] {
    var automaton = SuffixAutomaton()
    for c in word.utf8 { automaton.extend(c) }
    let s = Array(word.utf8)
    var brute = Set<ArraySlice<UInt8>>()
    for a in s.indices { for b in (a + 1)...s.count { brute.insert(s[a..<b]) } }
    print(word, "states:", automaton.len.count, "distinct:", automaton.distinctSubstrings, "brute force:", brute.count)
}

// 20,000 made-up letters from a, b and c, the same every run
var seed = 8
var automaton = SuffixAutomaton()
for _ in 0..<20_000 {
    seed = (seed * 1_103_515_245 + 12_345) % 2_147_483_648
    automaton.extend(97 + UInt8((seed >> 16) % 3))
}
print("n = 20000 states:", automaton.len.count, "(at most 2n - 1 = 39999)", "distinct:", automaton.distinctSubstrings)
