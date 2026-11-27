// Generated from src/dsa/content/lessons/string-algorithms/sa-z.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func zFunction<T: Equatable>(_ s: [T]) -> [Int] {
    let n = s.count
    var z = [Int](repeating: 0, count: n)
    var l = 0, r = 0
    for i in s.indices.dropFirst() {
        if i < r { z[i] = min(r - i, z[i - l]) }
        while i + z[i] < n && s[z[i]] == s[i + z[i]] { z[i] += 1 }
        if i + z[i] > r { l = i; r = i + z[i] }
    }
    return z
}

// p is a period when the suffix starting at p matches the start all the way to the end
for word in ["abcabcab", "abcabcabc", "aabaab", "abcd"] {
    let s = Array(word.utf8)
    let z = zFunction(s)
    let period = (1..<s.count).first { $0 + z[$0] == s.count } ?? s.count
    print(word, "z:", z, "smallest period:", period)
}
