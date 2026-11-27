// Generated from src/dsa/content/lessons/swift-strings/swift-substring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let sentence = "Swift strings are clever"
let firstWord = sentence.prefix(5)

print(firstWord)
print(type(of: firstWord))
print(type(of: sentence.dropFirst(6)))
print(type(of: sentence.split(separator: " ")))
