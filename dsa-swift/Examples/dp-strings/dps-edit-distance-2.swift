// Generated from src/dsa/content/lessons/dp-strings/dps-edit-distance.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func editTable(_ a: [Character], _ b: [Character]) -> [[Int]] {
    let n = a.count, m = b.count
    var table = Array(repeating: Array(repeating: 0, count: m + 1), count: n + 1)
    for i in 0...n {
        for j in 0...m {
            if i == 0 {
                table[i][j] = j
            } else if j == 0 {
                table[i][j] = i
            } else if a[i - 1] == b[j - 1] {
                table[i][j] = table[i - 1][j - 1]
            } else {
                table[i][j] = 1 + min(table[i - 1][j - 1], table[i - 1][j], table[i][j - 1])
            }
        }
    }
    return table
}

/// The edits, in order, that turn `first` into `second` with the fewest steps
func editScript(_ first: String, _ second: String) -> [String] {
    let a = Array(first), b = Array(second)
    let table = editTable(a, b)
    var steps: [String] = []
    var i = a.count, j = b.count
    while i > 0 || j > 0 {
        if i > 0 && j > 0 && a[i - 1] == b[j - 1] && table[i][j] == table[i - 1][j - 1] {
            steps.append("keep \(a[i - 1])")
            i -= 1
            j -= 1
        } else if i > 0 && j > 0 && table[i][j] == table[i - 1][j - 1] + 1 {
            steps.append("replace \(a[i - 1]) with \(b[j - 1])")
            i -= 1
            j -= 1
        } else if i > 0 && table[i][j] == table[i - 1][j] + 1 {
            steps.append("delete \(a[i - 1])")
            i -= 1
        } else {
            steps.append("insert \(b[j - 1])")
            j -= 1
        }
    }
    return steps.reversed()                           // found back to front
}

for step in editScript("kitten", "sitting") {
    print(step)
}
print("---")
print(editScript("sunday", "saturday").filter { !$0.hasPrefix("keep") })
print(editScript("", "ab"), editScript("ab", ""))
