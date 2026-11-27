// Generated from src/dsa/content/lessons/swift-generics/swift-associated-types.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Container {
    associatedtype Item
    mutating func append(_ item: Item)
    var count: Int { get }
    func item(at index: Int) -> Item
}

struct Bag<Element>: Container {
    private var items: [Element] = []
    mutating func append(_ item: Element) { items.append(item) }
    var count: Int { items.count }
    func item(at index: Int) -> Element { items[index] }
}

func lastItem<C: Container>(of container: C) -> C.Item? {
    container.count == 0 ? nil : container.item(at: container.count - 1)
}

func allItemsMatch<C1: Container, C2: Container>(_ first: C1, _ second: C2) -> Bool
    where C1.Item == C2.Item, C1.Item: Equatable {
    guard first.count == second.count else {
        return false
    }
    for index in 0..<first.count where first.item(at: index) != second.item(at: index) {
        return false
    }
    return true
}

var a = Bag<Int>()
var b = Bag<Int>()
for value in [3, 1, 4] {
    a.append(value)
    b.append(value)
}
print(lastItem(of: a) ?? -1)
print(allItemsMatch(a, b))
b.append(1)
print(allItemsMatch(a, b))
