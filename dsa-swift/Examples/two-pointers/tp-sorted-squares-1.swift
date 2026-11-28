// Generated from src/dsa/content/lessons/two-pointers/tp-sorted-squares.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [-7, -3, -1, 2, 4, 6]
print(numbers.map { $0 * $0 })
print(numbers.map { $0 * $0 }.sorted())
