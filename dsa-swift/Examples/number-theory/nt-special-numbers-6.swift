// Generated from src/dsa/content/lessons/number-theory/nt-special-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Every partition of n items, as a list of group labels: item i joins a group used before or a new one
func allPartitions(_ n: Int) -> [[Int]] {
    var result: [[Int]] = []
    var labels: [Int] = []
    func place(_ groups: Int) {
        if labels.count == n {
            result.append(labels)
            return
        }
        for group in 0...groups {          // groups 0..<groups exist; label `groups` opens a new one
            labels.append(group)
            place(group == groups ? groups + 1 : groups)
            labels.removeLast()
        }
    }
    place(0)
    return result
}

print(allPartitions(3))
for n in 1...6 {
    let all = allPartitions(n)
    let byGroups = (1...n).map { k in all.filter { ($0.max() ?? -1) + 1 == k }.count }
    print(n, all.count, byGroups)
}
