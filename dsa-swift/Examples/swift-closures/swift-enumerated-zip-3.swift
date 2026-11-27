// Generated from src/dsa/content/lessons/swift-closures/swift-enumerated-zip.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = ["Ada", "Ben", "Cleo"]
let scores = [72, 95, 64]

for (name, score) in zip(names, scores) {
    print("\(name): \(score)")
}

let prices = [3, 10, 4]
let quantities = [2, 1, 5]
let total = zip(prices, quantities).map { $0 * $1 }.reduce(0, +)
print(total)
