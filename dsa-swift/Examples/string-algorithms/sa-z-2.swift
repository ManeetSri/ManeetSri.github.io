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

let pattern = "abab", text = "abaababab"
let m = pattern.utf8.count
let combined = pattern.utf8.map { Int($0) } + [-1] + text.utf8.map { Int($0) }
let z = zFunction(combined)
let reach = Array(z[(m + 1)...])            // for each text position: how much of the pattern starts there
print("pattern prefix at each text position:", reach)
print("matches:", reach.indices.filter { reach[$0] == m })
