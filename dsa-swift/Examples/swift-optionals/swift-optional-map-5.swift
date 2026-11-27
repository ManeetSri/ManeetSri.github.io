// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-map.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let goodInput: String? = "42"
let badInput: String? = "forty-two"
let noInput: String? = nil

print(goodInput.flatMap { Int($0) })
print(badInput.flatMap { Int($0) })
print(noInput.flatMap { Int($0) })
