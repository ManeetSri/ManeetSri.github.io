// Generated from src/dsa/content/lessons/swift-collections/swift-array-basics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let zeros = Array(repeating: 0, count: 5)
let oneToFive = Array(1...5)
let firstFour = Array(0..<4)
let evens = Array(stride(from: 0, to: 10, by: 2))

print(zeros)
print(oneToFive)
print(firstFour)
print(evens)
