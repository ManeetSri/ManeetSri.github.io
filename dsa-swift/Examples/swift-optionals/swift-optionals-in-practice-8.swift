// Generated from src/dsa/content/lessons/swift-optionals/swift-optionals-in-practice.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let typed = ["78", "91", "abc", "65", "", "91"]
var scores: [Int] = []

for text in typed {
    if let score = Int(text) {
        scores.append(score)
    }
}

print("Valid scores: \(scores)")
if let best = scores.max(), let firstBest = scores.firstIndex(of: best) {
    print("Best: \(best), first scored by entry \(firstBest + 1)")
} else {
    print("No valid scores")
}
