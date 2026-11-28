// Generated from src/dsa/content/lessons/dp-strings/dps-lcs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// A line-by-line diff: "  " keeps a line, "- " deletes it, "+ " inserts one
func diff(_ old: [String], _ new: [String]) -> [String] {
    let n = old.count, m = new.count
    var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
    for i in 0...n {
        for j in 0...m {
            if i == 0 || j == 0 {
                table[i][j] = 0
            } else if old[i - 1] == new[j - 1] {
                table[i][j] = table[i - 1][j - 1] + 1
            } else {
                table[i][j] = max(table[i - 1][j], table[i][j - 1])
            }
        }
    }
    var lines: [String] = []
    var i = n, j = m
    while i > 0 || j > 0 {
        if i > 0 && j > 0 && old[i - 1] == new[j - 1] {
            lines.append("  " + old[i - 1])                     // in the LCS: unchanged
            i -= 1
            j -= 1
        } else if j > 0 && (i == 0 || table[i][j - 1] >= table[i - 1][j]) {
            lines.append("+ " + new[j - 1])                     // only in the new version
            j -= 1
        } else {
            lines.append("- " + old[i - 1])                     // only in the old version
            i -= 1
        }
    }
    return lines.reversed()
}

let before = ["buy milk", "call mum", "fix bike", "read book"]
let after = ["buy milk", "fix bike", "water plants", "read book", "sleep"]
for line in diff(before, after) {
    print(line)
}
