// Reference solution: Count distinct substrings of a long text. A suffix automaton: every distinct
// substring lives in exactly one state, and a state holds the lengths len[link] + 1 ... len, so the
// answer is the sum of len[v] - len[link[v]] over every state but the start. Transitions live in one
// flat array, 26 per state, with -1 for "none"; there are at most 2n states. (The suffix array gives
// the same answer as n(n + 1)/2 minus the sum of the LCP array.) O(n · 26) time and space.

public enum DistinctSubstringsAtScale {
    public static func count(in text: String) -> Int {
        let s = Array(text.utf8)
        let capacity = 2 * s.count + 1
        var len = [Int](repeating: 0, count: capacity)
        var link = [Int](repeating: -1, count: capacity)
        var next = [Int32](repeating: -1, count: 26 * capacity)
        var states = 1
        var last = 0

        for byte in s {
            let c = Int(byte - 97)
            let cur = states
            states += 1
            len[cur] = len[last] + 1
            link[cur] = 0
            var p = last
            while p != -1 && next[26 * p + c] == -1 {
                next[26 * p + c] = Int32(cur)
                p = link[p]
            }
            if p != -1 {
                let q = Int(next[26 * p + c])
                if len[p] + 1 == len[q] {
                    link[cur] = q
                } else {
                    let clone = states
                    states += 1
                    len[clone] = len[p] + 1
                    link[clone] = link[q]
                    for letter in 0..<26 { next[26 * clone + letter] = next[26 * q + letter] }
                    while p != -1 && next[26 * p + c] == Int32(q) {
                        next[26 * p + c] = Int32(clone)
                        p = link[p]
                    }
                    link[q] = clone
                    link[cur] = clone
                }
            }
            last = cur
        }

        var total = 0
        for v in 1..<states {
            total += len[v] - len[link[v]]
        }
        return total
    }
}
