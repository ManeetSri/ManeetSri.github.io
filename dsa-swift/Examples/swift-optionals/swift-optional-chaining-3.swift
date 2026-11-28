// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-chaining.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let searchText: String? = nil
let letterCount = searchText?.count ?? 0
print("Letters typed: \(letterCount)")

let words = ["swift", "is", "fun"]
let empty: [String] = []
print(words.last?.uppercased() ?? "nothing")
print(empty.last?.uppercased() ?? "nothing")
