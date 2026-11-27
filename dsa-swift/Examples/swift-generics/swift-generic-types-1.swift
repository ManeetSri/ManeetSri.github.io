// Generated from src/dsa/content/lessons/swift-generics/swift-generic-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct IntStack {
    private var items: [Int] = []

    mutating func push(_ item: Int) {
        items.append(item)
    }

    mutating func pop() -> Int? {
        items.popLast()
    }

    func peek() -> Int? {
        items.last
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    var count: Int {
        items.count
    }
}

var stack = IntStack()
stack.push(1)
stack.push(2)
stack.push(3)
print(stack.peek() ?? -1)
print(stack.pop() ?? -1)
print(stack.pop() ?? -1)
print(stack.count, stack.isEmpty)
