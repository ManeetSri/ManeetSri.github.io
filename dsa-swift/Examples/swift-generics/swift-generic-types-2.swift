// Generated from src/dsa/content/lessons/swift-generics/swift-generic-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Stack<Element> {
    private var items: [Element] = []

    mutating func push(_ item: Element) {
        items.append(item)
    }

    mutating func pop() -> Element? {
        items.popLast()
    }

    func peek() -> Element? {
        items.last
    }

    var isEmpty: Bool {
        items.isEmpty
    }

    var count: Int {
        items.count
    }
}

var numbers = Stack<Int>()
numbers.push(10)
numbers.push(20)
print(numbers.pop() ?? 0)

var words = Stack<String>()
words.push("first")
words.push("second")
print(words.peek() ?? "")
print(words.count)
