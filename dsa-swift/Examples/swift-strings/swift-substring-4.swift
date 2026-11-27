// Generated from src/dsa/content/lessons/swift-strings/swift-substring.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func shout(_ text: String) -> String {
    text.uppercased() + "!"
}

let sentence = "hello world"
let first = String(sentence.prefix(5))
print(shout(first))
print(type(of: first))
