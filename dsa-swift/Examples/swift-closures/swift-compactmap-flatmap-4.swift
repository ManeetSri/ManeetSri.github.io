// Generated from src/dsa/content/lessons/swift-closures/swift-compactmap-flatmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [1, 2, 3]

let nested = numbers.map { [$0, $0 * 10] }
print(nested)

let flat = numbers.flatMap { [$0, $0 * 10] }
print(flat)
