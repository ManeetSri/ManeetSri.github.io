// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-map.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let rawName: String? = "ada lovelace"
let title = rawName.map { name in name.uppercased() + "!" }
print(title ?? "No name")
