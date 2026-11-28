// Generated from src/dsa/content/lessons/swift-optionals/swift-if-let-guard-let.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var stack = [3, 8, 5]

while let top = stack.popLast() {
    print("Took \(top)")
}
print("Empty: \(stack.isEmpty)")
