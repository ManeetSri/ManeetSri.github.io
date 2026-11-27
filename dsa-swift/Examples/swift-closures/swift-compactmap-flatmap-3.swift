// Generated from src/dsa/content/lessons/swift-closures/swift-compactmap-flatmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let names = [1: "Ada", 2: "Ben", 4: "Dev"]
let requested = [4, 3, 1]
print(requested.compactMap { names[$0] })
