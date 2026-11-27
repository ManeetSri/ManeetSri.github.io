// Generated from src/dsa/content/lessons/swift-collections/swift-collections-are-values.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func addBonus(_ scores: inout [Int]) {
    for i in scores.indices {
        scores[i] += 5
    }
}

var mine = [70, 80]
addBonus(&mine)
print(mine)
