// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let letter: Character = "a"
let text: String = "a"
print(letter == "a", String(letter) == text)       // a literal can be either type
print(letter.isLetter, letter.asciiValue ?? 0)
let next = Character(UnicodeScalar(letter.asciiValue! + 1))
print(next)
let parts = "swift is fun".split(separator: " ")
print(parts.count, type(of: parts[0]))
let firstWord = String(parts[0])                   // convert before storing or returning
print(firstWord.uppercased())
