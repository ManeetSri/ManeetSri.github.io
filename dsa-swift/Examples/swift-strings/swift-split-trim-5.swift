// Generated from src/dsa/content/lessons/swift-strings/swift-split-trim.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let input = "3 14 15 92 x 6"
let numbers = input.split(separator: " ").compactMap { Int($0) }
print(numbers)
print(numbers.reduce(0, +))
