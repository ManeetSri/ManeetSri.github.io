// Generated from src/dsa/content/lessons/swift-optionals/swift-nil-coalescing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let userSetting: Int? = nil
let teamSetting: Int? = 14
let fontSize = userSetting ?? teamSetting ?? 12
print(fontSize)
