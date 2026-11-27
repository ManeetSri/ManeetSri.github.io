// Generated from src/dsa/content/lessons/design-structures/ds-iterators.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Item {
    case number(Int)
    case list([Item])
}

struct NestedIterator: IteratorProtocol {
    private var stack: [IndexingIterator<[Item]>]    // one iterator per list we're inside

    init(_ items: [Item]) {
        stack = [items.makeIterator()]
    }

    mutating func next() -> Int? {
        while !stack.isEmpty {
            // Advance the innermost iterator in place, inside the array
            guard let item = stack[stack.count - 1].next() else {
                stack.removeLast()                    // this list is used up
                print("  leave a list, depth now \(stack.count)")
                continue
            }
            switch item {
            case .number(let value):
                return value
            case .list(let inner):
                stack.append(inner.makeIterator())    // go one level deeper
                print("  enter a list of \(inner.count), depth now \(stack.count)")
            }
        }
        return nil
    }
}

let items: [Item] = [.number(1), .list([.number(2), .list([]), .number(3)]), .list([.list([.number(4)])])]
var numbers = NestedIterator(items)
print("created")
while let value = numbers.next() {
    print("next:", value)
}
