// Generated from src/dsa/content/lessons/swift-types-operators/swift-type-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let small: Int8 = 100
let big = Int(small) + 1_000
let byte = UInt8(200)
print(big, byte)
