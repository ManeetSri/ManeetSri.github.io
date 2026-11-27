// Generated from src/dsa/content/lessons/dp-strings/dps-common-substring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let a = Array("ABAB"), b = Array("BABA")
var table = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
for i in 0...a.count {
    for j in 0...b.count {
        if i == 0 || j == 0 {
            table[i][j] = 0
        } else if a[i - 1] == b[j - 1] {
            table[i][j] = table[i - 1][j - 1] + 1     // the common run grows by one
        } else {
            table[i][j] = 0                           // a mismatch breaks the run
        }
    }
}
print("  ∅ " + b.map(String.init).joined(separator: " "))
for i in 0...a.count {
    let label = i == 0 ? "∅" : String(a[i - 1])
    print(label + " " + table[i].map(String.init).joined(separator: " "))
}
