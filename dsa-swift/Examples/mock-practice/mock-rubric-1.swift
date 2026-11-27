// Generated from src/dsa/content/lessons/mock-practice/mock-rubric.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Outcome {
    case solved, solvedWithNudge, didNotFinish
}

// How the console turns a mock into a re-solve rating
func rating(_ outcome: Outcome, scores: [Int]) -> String {
    let average = Double(scores.reduce(0, +)) / Double(scores.count)
    if outcome == .didNotFinish || average < 2 { return "Again" }
    if average < 2.75 { return "Hard" }
    if average < 3.5 { return "Good" }
    return "Easy"
}

let mocks: [(Outcome, [Int])] = [
    (.solved, [3, 3, 4, 2, 3]),
    (.solved, [4, 4, 4, 3, 4]),
    (.solvedWithNudge, [2, 3, 2, 2, 3]),
    (.didNotFinish, [4, 4, 1, 4, 4]),
]
for (outcome, scores) in mocks {
    let average = Double(scores.reduce(0, +)) / Double(scores.count)
    print(scores, average, rating(outcome, scores: scores))
}
