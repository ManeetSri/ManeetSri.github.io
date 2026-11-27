// Generated from src/dsa/content/lessons/swift-closures/swift-capturing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let passMark = 50
let scores = [72, 38, 50, 91]

for score in scores {
    let hasPassed = { score >= passMark }
    print(score, hasPassed())
}
