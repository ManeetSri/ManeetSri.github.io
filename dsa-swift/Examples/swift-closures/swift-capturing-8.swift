// Generated from src/dsa/content/lessons/swift-closures/swift-capturing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["Ada", "Ben", "Cleo", "Dev"]
let scores = [72, 95, 64, 88]

let ranking = (0..<scores.count).sorted { scores[$0] > scores[$1] }
print(ranking)

for (place, index) in ranking.enumerated() {
    print("\(place + 1). \(names[index]) with \(scores[index])")
}
