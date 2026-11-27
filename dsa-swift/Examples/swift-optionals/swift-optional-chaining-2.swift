// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-chaining.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let teams = [
    "red": ["Ana", "Ben"],
    "blue": [String](),
]

print(teams["red"]?.first?.count)
print(teams["blue"]?.first?.count)
print(teams["green"]?.first?.count)
