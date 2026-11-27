// Generated from src/dsa/content/lessons/swift-strings/swift-character-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let messy = "Hello, World! 2024"
print(messy.filter { $0.isLetter })
print(messy.filter { $0.isNumber })
print(messy.filter { !$0.isWhitespace })
