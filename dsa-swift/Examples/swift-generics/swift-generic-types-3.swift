// Generated from src/dsa/content/lessons/swift-generics/swift-generic-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Stack<Element> {
    private var items: [Element] = []
    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop() -> Element? { items.popLast() }
    var isEmpty: Bool { items.isEmpty }
}

func reversed(_ text: String) -> String {
    var stack = Stack<Character>()
    for character in text {
        stack.push(character)
    }
    var result = ""
    while let character = stack.pop() {
        result.append(character)
    }
    return result
}

print(reversed("stressed"))
