// Generated from src/dsa/content/lessons/string-algorithms/sa-manacher.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var comparisons = 0                         // character comparisons, counted by both methods

func manacher(_ s: [UInt8]) -> [Int] {
    var t = [Int](repeating: -1, count: 2 * s.count + 1)
    for (k, c) in s.enumerated() { t[2 * k + 1] = Int(c) }
    let n = t.count
    var rad = [Int](repeating: 0, count: n)
    var centre = 0, right = 0
    for i in 0..<n {
        if i < right { rad[i] = min(rad[2 * centre - i], right - i) }
        while i - rad[i] - 1 >= 0 && i + rad[i] + 1 < n {
            comparisons += 1
            if t[i - rad[i] - 1] != t[i + rad[i] + 1] { break }
            rad[i] += 1
        }
        if i + rad[i] > right { centre = i; right = i + rad[i] }
    }
    return rad
}

// Expand around every centre, from M23
func expandCount(_ s: [UInt8]) -> Int {
    var count = 0
    for centre in 0..<(2 * s.count - 1) {
        var low = centre / 2, high = low + centre % 2
        while low >= 0 && high < s.count {
            comparisons += 1
            if s[low] != s[high] { break }
            count += 1
            low -= 1
            high += 1
        }
    }
    return count
}

for word in ["abc", "aaa", "abba", "abaaba", "racecar"] {
    let s = Array(word.utf8)
    print(word, manacher(s).reduce(0) { $0 + ($1 + 1) / 2 }, expandCount(s))
}

let many = Array(String(repeating: "a", count: 2_000).utf8)
comparisons = 0
let a = expandCount(many)
print("expand around centre:", a, "palindromes,", comparisons, "comparisons")
comparisons = 0
let b = manacher(many).reduce(0) { $0 + ($1 + 1) / 2 }
print("Manacher:            ", b, "palindromes,", comparisons, "comparisons")
