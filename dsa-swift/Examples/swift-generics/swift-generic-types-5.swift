// Generated from src/dsa/content/lessons/swift-generics/swift-generic-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Stack<Element> {
    private var items: [Element] = []
    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop() -> Element? { items.popLast() }

    var bottomToTop: [Element] {
        items
    }
}

extension Stack: CustomStringConvertible {
    var description: String {
        "Stack " + bottomToTop.map { "\($0)" }.joined(separator: " | ") + " <- top"
    }
}

extension Stack where Element: Equatable {
    func contains(_ item: Element) -> Bool {
        bottomToTop.contains(item)
    }
}

var stack = Stack<Int>()
for value in [4, 8, 15] {
    stack.push(value)
}
print(stack)
print(stack.contains(8))
