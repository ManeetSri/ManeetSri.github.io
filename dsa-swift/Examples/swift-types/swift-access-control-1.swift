// Generated from src/dsa/content/lessons/swift-types/swift-access-control.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct NumberStack {
    private var items: [Int] = []

    mutating func push(_ value: Int) {
        items.append(value)
    }

    func peek() -> Int? {
        items.last
    }
}

var stack = NumberStack()
stack.push(4)
stack.push(9)
print(stack.peek() ?? -1)
