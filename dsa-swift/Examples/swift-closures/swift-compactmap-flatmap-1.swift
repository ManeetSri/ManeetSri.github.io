// Generated from src/dsa/content/lessons/swift-closures/swift-compactmap-flatmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let entries = ["12", "seven", "5", "", "40"]

let attempts = entries.map { Int($0) }
print(attempts)

let numbers = entries.compactMap { Int($0) }
print(numbers)
