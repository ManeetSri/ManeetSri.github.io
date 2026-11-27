// Generated from src/dsa/content/lessons/capstones/cap-spell-checker.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Optimal string alignment: Levenshtein plus "swap two neighbours" for 1, but no substring
/// may be edited again after a swap
func osa(_ a: [Character], _ b: [Character]) -> Int {
    var d = Array(repeating: Array(repeating: 0, count: b.count + 1), count: a.count + 1)
    for i in 0...a.count { d[i][0] = i }
    for j in 0...b.count { d[0][j] = j }
    for i in stride(from: 1, through: a.count, by: 1) {
        for j in stride(from: 1, through: b.count, by: 1) {
            let cost = a[i - 1] == b[j - 1] ? 0 : 1
            d[i][j] = min(d[i - 1][j] + 1, d[i][j - 1] + 1, d[i - 1][j - 1] + cost)
            if i > 1, j > 1, a[i - 1] == b[j - 2], a[i - 2] == b[j - 1] {
                d[i][j] = min(d[i][j], d[i - 2][j - 2] + 1)
            }
        }
    }
    return d[a.count][b.count]
}

/// True Damerau–Levenshtein (Lowrance–Wagner): swaps may be edited further, and it's a metric
func damerau(_ a: [Character], _ b: [Character]) -> Int {
    let far = a.count + b.count
    var d = Array(repeating: Array(repeating: 0, count: b.count + 2), count: a.count + 2)
    d[0][0] = far
    for i in 0...a.count { d[i + 1][0] = far; d[i + 1][1] = i }
    for j in 0...b.count { d[0][j + 1] = far; d[1][j + 1] = j }
    var lastRow: [Character: Int] = [:]                  // the last row where each character appeared in a
    for i in stride(from: 1, through: a.count, by: 1) {
        var lastMatchColumn = 0
        for j in stride(from: 1, through: b.count, by: 1) {
            let k = lastRow[b[j - 1]] ?? 0
            let l = lastMatchColumn
            var cost = 1
            if a[i - 1] == b[j - 1] {
                cost = 0
                lastMatchColumn = j
            }
            d[i + 1][j + 1] = min(d[i][j] + cost,             // match or replace
                                  d[i + 1][j] + 1,            // insert
                                  d[i][j + 1] + 1,            // delete
                                  d[k][l] + (i - k - 1) + 1 + (j - l - 1))   // swap, with edits between
        }
        lastRow[a[i - 1]] = i
    }
    return d[a.count + 1][b.count + 1]
}

for (name, distance) in [("OSA", osa), ("Damerau", damerau)] {
    let ca = distance(Array("CA"), Array("AC")), ac = distance(Array("AC"), Array("ABC"))
    let direct = distance(Array("CA"), Array("ABC"))
    print("\(name): CA→AC \(ca), AC→ABC \(ac), CA→ABC \(direct)", direct <= ca + ac ? "ok" : "breaks the triangle inequality")
}
print("teh→the:", damerau(Array("teh"), Array("the")), "| wrod→word:", damerau(Array("wrod"), Array("word")))
