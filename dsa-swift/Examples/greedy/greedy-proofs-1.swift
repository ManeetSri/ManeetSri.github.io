// Generated from src/dsa/content/lessons/greedy/greedy-proofs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func selectTalks(_ talks: [[Int]]) -> [[Int]] {
    var kept: [[Int]] = []
    var lastEnd = Int.min
    for talk in talks.sorted(by: { $0[1] < $1[1] }) where talk[0] >= lastEnd {
        kept.append(talk)
        lastEnd = talk[1]
    }
    return kept
}

let talks = [[2, 5], [1, 3], [4, 7], [6, 9], [3, 8], [8, 10], [9, 12], [7, 11], [11, 14]]
let greedy = selectTalks(talks)
let other = [[1, 3], [3, 8], [8, 10], [11, 14]]      // another valid choice of four talks
print(greedy)
for i in greedy.indices {
    print("talk \(i + 1): greedy ends at \(greedy[i][1]), the other at \(other[i][1])")
}
