// Generated from src/dsa/content/lessons/swift-strings/swift-character-properties.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let password = "Sw1ft rocks!"
var letters = 0
var digits = 0
var spaces = 0
var others = 0

for ch in password {
    if ch.isLetter {
        letters += 1
    } else if ch.isNumber {
        digits += 1
    } else if ch.isWhitespace {
        spaces += 1
    } else {
        others += 1
    }
}
print(letters, digits, spaces, others)
