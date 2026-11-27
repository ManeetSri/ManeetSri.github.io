// Generated from src/dsa/content/lessons/swift-closures/swift-sorting-searching-api.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let words = ["kiwi", "fig", "banana", "plum"]

let shortest = words.min { $0.count < $1.count }
let longest = words.max { $0.count < $1.count }
print(shortest ?? "none", longest ?? "none")
