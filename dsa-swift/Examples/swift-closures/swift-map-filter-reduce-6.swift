// Generated from src/dsa/content/lessons/swift-closures/swift-map-filter-reduce.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [3, 5, 2]
print(numbers.reduce(0, +))
print(numbers.reduce(1, *))
print(numbers.reduce(0) { $0 + $1 * $1 })
