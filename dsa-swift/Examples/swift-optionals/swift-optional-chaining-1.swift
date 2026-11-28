// Generated from src/dsa/content/lessons/swift-optionals/swift-optional-chaining.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let nickname: String? = "maverick"
let noNickname: String? = nil

print(nickname?.count)
print(nickname?.uppercased())
print(noNickname?.count)
