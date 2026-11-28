// Generated from src/dsa/content/lessons/swift-functions/swift-inout-swap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func addBonus(_ bonus: Int, to scores: inout [Int]) {
    for index in 0..<scores.count {
        scores[index] += bonus
    }
}

var scores = [60, 72, 55]
addBonus(5, to: &scores)
print(scores)
