// Generated from src/dsa/content/lessons/swift-generics/swift-array-literal.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Stack<Element> {
    private var items: [Element] = []

    mutating func push(_ item: Element) {
        items.append(item)
    }

    mutating func pop() -> Element? {
        items.popLast()
    }

    var count: Int {
        items.count
    }
}

extension Stack: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        items = elements
    }
}

var stack: Stack = [1, 2, 3]
print(stack.count)
print(stack.pop() ?? 0)

var empty: Stack<String> = []
empty.push("only")
print(empty.count)
