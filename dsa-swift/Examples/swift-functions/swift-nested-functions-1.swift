// Generated from src/dsa/content/lessons/swift-functions/swift-nested-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func printReport(for scores: [Int]) {
    func label(for score: Int) -> String {
        if score >= 70 {
            return "distinction"
        } else if score >= 40 {
            return "pass"
        } else {
            return "fail"
        }
    }

    for score in scores {
        print("\(score): \(label(for: score))")
    }
}

printReport(for: [82, 45, 12])
