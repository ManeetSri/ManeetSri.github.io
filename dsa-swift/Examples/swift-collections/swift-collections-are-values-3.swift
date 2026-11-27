// Generated from src/dsa/content/lessons/swift-collections/swift-collections-are-values.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func addBonus(_ scores: [Int]) -> [Int] {
    var adjusted = scores
    for i in adjusted.indices {
        adjusted[i] += 5
    }
    return adjusted
}

let scores = [70, 80]
let boosted = addBonus(scores)
print(scores, boosted)
