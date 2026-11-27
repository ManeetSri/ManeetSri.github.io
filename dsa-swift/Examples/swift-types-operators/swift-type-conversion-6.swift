// Generated from src/dsa/content/lessons/swift-types-operators/swift-type-conversion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let typed = "42"
let notANumber = "hello"
print(Int(typed) == 42)
print(Int(notANumber) == nil)
print(Int("4.2") == nil)
