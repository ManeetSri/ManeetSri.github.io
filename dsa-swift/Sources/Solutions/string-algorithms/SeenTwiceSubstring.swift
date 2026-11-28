// Reference solution: Longest substring that appears twice. Two occurrences of a substring are two
// suffixes that start with it, and the pair of suffixes sharing the longest start are neighbours in
// sorted order. So build the suffix array (prefix doubling, with a counting sort each round) and the
// LCP array (Kasai), and return the largest LCP. Occurrences may overlap, which this allows.
// O(n log n) time, O(n) space.

public enum SeenTwiceSubstring {
    public static func longestLength(in text: String) -> Int {
        let s = Array(text.utf8)
        guard s.count > 1 else { return 0 }
        let sa = suffixArray(s)
        return lcpArray(s, sa).max() ?? 0
    }

    /// Sorts the cyclic shifts of text + sentinel, doubling the compared length each round, with a
    /// counting sort by rank each time. O(n log n).
    static func suffixArray(_ text: [UInt8]) -> [Int] {
        let n = text.count + 1                          // one extra position for the sentinel
        var rank = [Int](repeating: 0, count: n)        // the sentinel keeps rank 0, below every byte
        for i in text.indices { rank[i] = Int(text[i]) + 1 }
        var sa = [Int](repeating: 0, count: n)
        var count = [Int](repeating: 0, count: max(257, n))
        for i in 0..<n { count[rank[i]] += 1 }
        for c in 1..<count.count { count[c] += count[c - 1] }
        for i in stride(from: n - 1, through: 0, by: -1) {
            count[rank[i]] -= 1
            sa[count[rank[i]]] = i
        }
        var newRank = [Int](repeating: 0, count: n)
        var classes = 1
        for p in 1..<n {
            if rank[sa[p]] != rank[sa[p - 1]] { classes += 1 }
            newRank[sa[p]] = classes - 1
        }
        swap(&rank, &newRank)

        var shifted = [Int](repeating: 0, count: n)
        var k = 1
        while classes < n {
            // Sorted by the second half already: start each suffix k places earlier, wrapping round
            for p in 0..<n {
                let start = sa[p] - k
                shifted[p] = start < 0 ? start + n : start
            }
            // A stable counting sort by the first half's rank
            for c in 0..<classes { count[c] = 0 }
            for start in shifted { count[rank[start]] += 1 }
            for c in 1..<classes { count[c] += count[c - 1] }
            for start in shifted.reversed() {
                count[rank[start]] -= 1
                sa[count[rank[start]]] = start
            }
            // Equal (first half, second half) rank pairs share a new rank
            newRank[sa[0]] = 0
            classes = 1
            for p in 1..<n {
                let a = sa[p], b = sa[p - 1]
                let aSecond = a + k < n ? a + k : a + k - n
                let bSecond = b + k < n ? b + k : b + k - n
                if rank[a] != rank[b] || rank[aSecond] != rank[bSecond] { classes += 1 }
                newRank[a] = classes - 1
            }
            swap(&rank, &newRank)
            k *= 2
        }
        return Array(sa.dropFirst())                    // the sentinel's suffix sorts first
    }

    /// Kasai: lcp[p] is the common prefix of the suffixes at sa[p - 1] and sa[p]. O(n).
    static func lcpArray(_ s: [UInt8], _ sa: [Int]) -> [Int] {
        let n = s.count
        var rank = [Int](repeating: 0, count: n)
        for (p, start) in sa.enumerated() { rank[start] = p }
        var lcp = [Int](repeating: 0, count: n)
        var h = 0
        for i in 0..<n {
            if rank[i] == 0 {
                h = 0
                continue
            }
            let j = sa[rank[i] - 1]
            while i + h < n && j + h < n && s[i + h] == s[j + h] { h += 1 }
            lcp[rank[i]] = h
            if h > 0 { h -= 1 }
        }
        return lcp
    }
}
