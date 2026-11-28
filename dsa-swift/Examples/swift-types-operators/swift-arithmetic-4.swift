// Generated from src/dsa/content/lessons/swift-types-operators/swift-arithmetic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let position = -7
let count = 3
let wrapped = ((position % count) + count) % count
print(wrapped)
