// Generated from src/dsa/content/lessons/swift-optionals/swift-why-nil.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let ages = ["Ana": 31, "Ben": 27]
let numbers = [8, 3, 5]
let empty: [Int] = []

print(Int("42"))       // text that is a number
print(Int("hello"))    // text that isn't
print(ages["Ana"])     // a key that exists
print(ages["Zoe"])     // a key that doesn't
print(numbers.first)
print(empty.first)
