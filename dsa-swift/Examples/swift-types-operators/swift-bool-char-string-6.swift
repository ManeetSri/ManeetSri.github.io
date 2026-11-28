// Generated from src/dsa/content/lessons/swift-types-operators/swift-bool-char-string.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var greeting = "Hello"
greeting += ", Maneet"
let exclamation: Character = "!"
greeting.append(exclamation)
print(greeting)
print(greeting == "Hello, Maneet!")
