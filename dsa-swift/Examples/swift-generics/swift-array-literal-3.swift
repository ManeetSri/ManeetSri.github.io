// Generated from src/dsa/content/lessons/swift-generics/swift-array-literal.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Stack<Element> {
    private var items: [Element] = []
    mutating func pop() -> Element? { items.popLast() }
    func peek() -> Element? { items.last }
}

extension Stack: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        items = elements
    }
}

func describeTop(of stack: Stack<String>) -> String {
    "Top: \(stack.peek() ?? "nothing")"
}

print(describeTop(of: ["plates", "cups", "bowls"]))
print(describeTop(of: []))
