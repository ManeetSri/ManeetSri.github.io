// Generated from src/dsa/content/lessons/swift-functions/swift-function-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isGreater(_ a: Int, _ b: Int) -> Bool {
    a > b
}

let scores = [40, 95, 70, 12]
print(scores.sorted(by: isGreater))
print(scores.sorted(by: >))
