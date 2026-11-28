// Generated from src/dsa/content/lessons/swift-types-operators/swift-ternary-ranges.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let probability = 0.0...1.0
print(probability.contains(0.25))
let lowercase: ClosedRange<Character> = "a"..."z"
print(lowercase.contains("q"))
print(lowercase.contains("Q"))
