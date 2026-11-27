// Generated from src/dsa/content/lessons/swift-types-operators/swift-overflow.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var hash: UInt8 = 17
hash = hash &* 31 &+ 65
print(hash)
