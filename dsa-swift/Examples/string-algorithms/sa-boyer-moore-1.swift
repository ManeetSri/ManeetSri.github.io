// Generated from src/dsa/content/lessons/string-algorithms/sa-boyer-moore.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Boyer–Moore with the bad-character rule: compare right to left, and skip on a mismatch
func boyerMoore(_ pattern: [UInt8], in text: [UInt8], trace: Bool = false) -> [Int] {
    let m = pattern.count, n = text.count
    guard m > 0, m <= n else { return [] }
    var last = [Int](repeating: -1, count: 256)         // last[c]: where byte c last occurs in the pattern
    for (k, c) in pattern.enumerated() {
        last[Int(c)] = k
    }
    var result: [Int] = []
    var s = 0                                           // the pattern's first character is under text[s]
    while s <= n - m {
        var j = m - 1
        while j >= 0 && pattern[j] == text[s + j] {
            j -= 1                                      // right to left
        }
        if j < 0 {
            result.append(s)
            s += s + m < n ? m - last[Int(text[s + m])] : 1     // line up the next text character
        } else {
            let bad = text[s + j]
            let shift = max(1, j - last[Int(bad)])      // line up the bad character's last occurrence
            if trace {
                print("s = \(s): mismatch at j = \(j) on '\(Character(UnicodeScalar(bad)))', shift \(shift)")
            }
            s += shift
        }
    }
    return result
}

let text = Array("here is a simple example".utf8)
print(boyerMoore(Array("example".utf8), in: text, trace: true))
print(boyerMoore(Array("aa".utf8), in: Array("aaaa".utf8)), boyerMoore(Array("abra".utf8), in: Array("abracadabra".utf8)))
