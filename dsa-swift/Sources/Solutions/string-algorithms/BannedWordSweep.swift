// Reference solution: Count banned words in a message. Aho–Corasick: a trie of the words with a flat
// 26-slot table per node, failure links built by BFS, and missing children filled in so the scan is
// one lookup per letter. During the scan, count how often each node is visited. Reaching a node also
// means its failure link's string ends here, so push each node's count onto its link, deepest nodes
// first (reverse BFS order); then a node's total is how often its string occurs. Each word's answer is
// the total at its end node, which also handles duplicate words. O(L · 26 + n) for total word length
// L and message length n, however many matches there are.

public enum BannedWordSweep {
    public static func counts(of words: [String], in message: String) -> [Int] {
        var next = [Int32](repeating: -1, count: 26)
        var nodes = 1
        var endNode = [Int](repeating: 0, count: words.count)
        for (index, word) in words.enumerated() {
            var node = 0
            for byte in word.utf8 {
                let slot = 26 * node + Int(byte - 97)
                if next[slot] == -1 {
                    next[slot] = Int32(nodes)
                    nodes += 1
                    next.append(contentsOf: repeatElement(-1, count: 26))
                }
                node = Int(next[slot])
            }
            endNode[index] = node
        }

        var link = [Int](repeating: 0, count: nodes)
        var order: [Int] = []
        for c in 0..<26 {
            if next[c] == -1 {
                next[c] = 0
            } else {
                order.append(Int(next[c]))
            }
        }
        var head = 0
        while head < order.count {
            let v = order[head]
            head += 1
            for c in 0..<26 {
                let child = Int(next[26 * v + c])
                let fallback = next[26 * link[v] + c]
                if child != -1 {
                    link[child] = Int(fallback)
                    order.append(child)
                } else {
                    next[26 * v + c] = fallback
                }
            }
        }

        var visits = [Int](repeating: 0, count: nodes)
        var node = 0
        for byte in message.utf8 {
            node = Int(next[26 * node + Int(byte - 97)])
            visits[node] += 1
        }
        for v in order.reversed() {
            visits[link[v]] += visits[v]
        }
        return endNode.map { visits[$0] }
    }
}
