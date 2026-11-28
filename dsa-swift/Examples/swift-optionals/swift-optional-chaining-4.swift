// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-chaining.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let scores = ["Ana": [72, 91, 85], "Ben": [64]]

if let best = scores["Ana"]?.max() {
    print("Ana's best score: \(best)")
}
if let best = scores["Cleo"]?.max() {
    print("Cleo's best score: \(best)")
} else {
    print("No scores for Cleo")
}
