// Generated from src/dsa/content/lessons/dp-strings/dps-edit-distance.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func editTable(_ a: [Character], _ b: [Character]) -> [[Int]] {
    let n = a.count, m = b.count
    var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
    for i in 0...n {
        for j in 0...m {
            if i == 0 {
                table[i][j] = j                             // build b's first j letters by inserting
            } else if j == 0 {
                table[i][j] = i                             // delete all i letters of a
            } else if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1]           // same letter: no edit needed
            } else {
                table[i][j] = 1 + min(table[i - 1][j - 1],  // replace a[i - 1] with b[j - 1]
                                      table[i - 1][j],      // delete a[i - 1]
                                      table[i][j - 1])      // insert b[j - 1]
            }
        }
    }
    return table
}

let a = Array("kitten"), b = Array("sitting")
let table = editTable(a, b)
print("  ∅ " + b.map(String.init).joined(separator: " "))
for i in 0...a.count {
    let label = i == 0 ? "∅" : String(a[i - 1])
    print(label + " " + table[i].map(String.init).joined(separator: " "))
}
print("distance:", table[a.count][b.count])
