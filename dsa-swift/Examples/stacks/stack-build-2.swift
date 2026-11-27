// Generated from src/dsa/content/lessons/stacks/stack-build.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Stack<Element> {
    private var storage: [Element] = []
    init(_ elements: [Element]) { storage = elements }
    mutating func push(_ element: Element) { storage.append(element) }
    @discardableResult mutating func pop() -> Element? { storage.popLast() }
    var bottomToTop: [Element] { storage }
}

var original = Stack(["a", "b"])
var copy = original
copy.push("c")
original.pop()
print(original.bottomToTop)
print(copy.bottomToTop)
