// Generated from src/dsa/content/lessons/swift-collections/swift-array-mutation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var stack = [10, 20, 30, 40, 50]

let removed = stack.remove(at: 1)
print(removed, stack)

let last = stack.removeLast()
print(last, stack)

let first = stack.removeFirst()
print(first, stack)

stack.removeAll()
print(stack, stack.isEmpty)
