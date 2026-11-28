// Generated from src/dsa/content/lessons/dp-strings/dps-lcs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func lcsTable(_ a: [Character], _ b: [Character]) -> [[Int]] {
    let n = a.count, m = b.count
    var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
    for i in 0...n {
        for j in 0...m {
            if i == 0 || j == 0 {
                table[i][j] = 0                                         // an empty prefix
            } else if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1] + 1                   // keep the matching pair
            } else {
                table[i][j] = max(table[i - 1][j], table[i][j - 1])     // drop one last letter
            }
        }
    }
    return table
}

let a = Array("ABCBDAB"), b = Array("BDCABA")
let table = lcsTable(a, b)
print("  ∅ " + b.map(String.init).joined(separator: " "))
for i in 0...a.count {
    let label = i == 0 ? "∅" : String(a[i - 1])
    print(label + " " + table[i].map(String.init).joined(separator: " "))
}
print("LCS length:", table[a.count][b.count])
