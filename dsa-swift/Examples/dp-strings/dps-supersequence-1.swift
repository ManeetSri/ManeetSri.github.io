// Generated from src/dsa/content/lessons/dp-strings/dps-supersequence.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lcsTable(_ a: [Character], _ b: [Character]) -> [[Int]] {
    let n = a.count, m = b.count
    var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
    for i in 0...n {
        for j in 0...m {
            if i == 0 || j == 0 {
                table[i][j] = 0
            } else if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1] + 1
            } else {
                table[i][j] = max(table[i - 1][j], table[i][j - 1])
            }
        }
    }
    return table
}

/// A shortest string that contains both `first` and `second` as subsequences
func shortestSupersequence(_ first: String, _ second: String) -> String {
    let a = Array(first), b = Array(second)
    let table = lcsTable(a, b)
    var result: [Character] = []
    var i = a.count, j = b.count
    while i > 0 && j > 0 {
        if a[i - 1] == b[j - 1] {
            result.append(a[i - 1])            // shared letter: write it once
            i -= 1
            j -= 1
        } else if table[i - 1][j] >= table[i][j - 1] {
            result.append(a[i - 1])            // a[i - 1] isn't shared: write it on its own
            i -= 1
        } else {
            result.append(b[j - 1])            // b[j - 1] isn't shared
            j -= 1
        }
    }
    while i > 0 {                              // whatever is left of either string
        result.append(a[i - 1])
        i -= 1
    }
    while j > 0 {
        result.append(b[j - 1])
        j -= 1
    }
    return String(result.reversed())
}

func isSubsequence(_ small: String, of big: String) -> Bool {
    var remaining = small[...]
    for character in big where character == remaining.first {
        remaining = remaining.dropFirst()
    }
    return remaining.isEmpty
}

for (first, second) in [("abac", "cab"), ("brute", "groot"), ("swift", "shift"), ("", "xyz"), ("aaa", "aaa")] {
    let merged = shortestSupersequence(first, second)
    print(first, second, merged, merged.count, isSubsequence(first, of: merged) && isSubsequence(second, of: merged))
}
