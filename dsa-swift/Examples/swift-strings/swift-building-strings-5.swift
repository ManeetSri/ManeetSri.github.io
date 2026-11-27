// Generated from src/dsa/content/lessons/swift-strings/swift-building-strings.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [3, 1, 4, 1, 5]
print(numbers.map(String.init).joined(separator: "-"))
print(numbers.map { String($0) }.joined(separator: " + "))
