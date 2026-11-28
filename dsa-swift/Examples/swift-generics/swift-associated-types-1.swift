// Generated from src/dsa/content/lessons/swift-generics/swift-associated-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Container {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    func item(at index: Int) -> Item
}

struct Stack<Element>: Container {
    private var items: [Element] = []

    mutating func push(_ item: Element) {
        items.append(item)
    }

    mutating func pop() -> Element? {
        items.popLast()
    }

    // Container requirements
    mutating func append(_ item: Element) {
        push(item)
    }

    var count: Int {
        items.count
    }

    func item(at index: Int) -> Element {
        items[index]
    }
}

struct EvenNumbers: Container {
    private var numbers: [Int] = []

    mutating func append(_ item: Int) {
        if item % 2 == 0 {
            numbers.append(item)
        }
    }

    var count: Int {
        numbers.count
    }

    func item(at index: Int) -> Int {
        numbers[index]
    }
}

var words = Stack<String>()
words.append("tea")
words.append("cake")
print(words.count, words.item(at: 1))

var evens = EvenNumbers()
for value in 1...6 {
    evens.append(value)
}
print(evens.count, evens.item(at: 0))
