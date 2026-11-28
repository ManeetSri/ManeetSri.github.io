// Generated from src/dsa/content/lessons/arrays/arrays-merge-sorted.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

typealias Score = (name: String, points: Int)

func mergeByPoints(_ first: [Score], _ second: [Score]) -> [Score] {
    var result: [Score] = []
    var i = 0
    var j = 0
    while i < first.count && j < second.count {
        if first[i].points <= second[j].points {
            result.append(first[i])
            i += 1
        } else {
            result.append(second[j])
            j += 1
        }
    }
    result.append(contentsOf: first[i...])
    result.append(contentsOf: second[j...])
    return result
}

let monday: [Score] = [("Ana", 10), ("Ben", 30)]
let tuesday: [Score] = [("Cy", 10), ("Di", 20)]
for score in mergeByPoints(monday, tuesday) {
    print(score.name, score.points)
}
