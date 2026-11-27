// Generated from src/dsa/content/lessons/swift-closures/swift-map-filter-reduce.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let temperatures = [18, 23, 9]
let labels = temperatures.map { "\($0)°C" }
print(labels)

let lengths = ["kiwi", "banana", "fig"].map { $0.count }
print(lengths)

let squares = (1...5).map { $0 * $0 }
print(squares)
