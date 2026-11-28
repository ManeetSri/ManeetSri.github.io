// Generated from src/dsa/content/lessons/swift-control-flow/swift-for-in.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let scores = ["Ana": 92, "Ben": 78, "Cleo": 85]

for (name, score) in scores.sorted(by: <) {
    print("\(name) scored \(score)")
}

var total = 0
for (_, score) in scores {
    total += score
}
print("Total: \(total)")
