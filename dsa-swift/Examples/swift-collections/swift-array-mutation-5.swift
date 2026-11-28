// Generated from src/dsa/content/lessons/swift-collections/swift-array-mutation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var numbers = [3, 8, 1, 6, 7, 2]
numbers.removeAll(where: { $0 % 2 == 0 })
print(numbers)
