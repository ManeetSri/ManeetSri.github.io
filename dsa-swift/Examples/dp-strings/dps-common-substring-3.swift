// Generated from src/dsa/content/lessons/dp-strings/dps-common-substring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

/// Length only, with one row. j runs downwards so row[j - 1] still holds the previous row's value.
func commonSubstringLength(_ first: String, _ second: String) -> Int {
    let a = Array(first), b = Array(second)
    var row = Array(repeating: 0, count: b.count + 1)
    var best = 0
    for i in 0..<a.count {
        for j in stride(from: b.count, through: 1, by: -1) {
            row[j] = a[i] == b[j - 1] ? row[j - 1] + 1 : 0
            best = max(best, row[j])
        }
    }
    return best
}

print(commonSubstringLength("photograph", "tomography"))
print(commonSubstringLength("aaaa", "aaa"))
print(commonSubstringLength("", "abc"))
