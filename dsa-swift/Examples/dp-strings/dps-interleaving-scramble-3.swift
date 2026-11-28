// Generated from src/dsa/content/lessons/dp-strings/dps-interleaving-scramble.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Is `target` a scramble of `source`? memo[length][i][j] remembers the answer for
/// source[i..<i + length] against target[j..<j + length]: 0 unknown, 1 yes, 2 no.
func isScramble(_ source: String, _ target: String) -> Bool {
    let s = Array(source), t = Array(target)
    let n = s.count
    guard t.count == n else { return false }
    if n == 0 { return true }
    var memo = Array(repeating: Array(repeating: Array(repeating: 0, count: n), count: n), count: n + 1)

    func check(_ i: Int, _ j: Int, _ length: Int) -> Bool {
        if length == 1 {
            return s[i] == t[j]
        }
        if memo[length][i][j] != 0 {
            return memo[length][i][j] == 1
        }
        var answer = false
        for k in 1..<length where !answer {             // split after k letters
            answer = (check(i, j, k) && check(i + k, j + k, length - k))                 // kept in order
                || (check(i, j + length - k, k) && check(i + k, j, length - k))           // swapped
        }
        memo[length][i][j] = answer ? 1 : 2
        return answer
    }

    return check(0, 0, n)
}

print(isScramble("swift", "ftisw"))
print(isScramble("swift", "tfiws"))
print(isScramble("abcd", "bdac"))
print(isScramble("abcd", "cadb"))
print(isScramble("abcd", "dcba"))
print(isScramble("ab", "ba"), isScramble("", ""), isScramble("a", "b"))

func permutations(_ items: [Character]) -> [[Character]] {
    if items.count <= 1 { return [items] }
    return items.indices.flatMap { index -> [[Character]] in
        var rest = items
        let first = rest.remove(at: index)
        return permutations(rest).map { [first] + $0 }
    }
}
for word in ["ab", "abc", "abcd", "abcde"] {
    let count = permutations(Array(word)).filter { isScramble(word, String($0)) }.count
    print(word, count)
}
