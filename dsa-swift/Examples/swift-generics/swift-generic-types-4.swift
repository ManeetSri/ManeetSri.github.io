// Generated from src/dsa/content/lessons/swift-generics/swift-generic-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Stack<Element> {
    private var items: [Element] = []
    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop() -> Element? { items.popLast() }
    func peek() -> Element? { items.last }
}

var history = Stack<String>()
var document = ""

for edit in ["Hello", ", world", "!!!"] {
    history.push(document)
    document += edit
}
print(document)

if let previous = history.pop() {
    document = previous
}
print(document)
if let previous = history.pop() {
    document = previous
}
print(document)
