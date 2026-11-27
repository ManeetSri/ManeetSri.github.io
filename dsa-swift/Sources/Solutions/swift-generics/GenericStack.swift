// Reference solution: A generic stack. The top of the stack is the end of a private array, so push is
// amortised O(1) and pop, peek, isEmpty and count are O(1). finalText is O(n) for n edits.

public enum GenericStack {
    public struct Stack<Element> {
        private var items: [Element] = []

        public init() {}

        public mutating func push(_ element: Element) {
            items.append(element)
        }

        public mutating func pop() -> Element? {
            items.popLast()
        }

        public func peek() -> Element? {
            items.last
        }

        public var isEmpty: Bool {
            items.isEmpty
        }

        public var count: Int {
            items.count
        }
    }

    // Words go on a stack; UNDO pops the most recent one. Popping everything at the end gives the
    // words newest first, so they're reversed before joining.
    public static func finalText(after edits: [String]) -> String {
        var words = Stack<String>()
        for edit in edits {
            if edit == "UNDO" {
                _ = words.pop()
            } else {
                words.push(edit)
            }
        }
        var newestFirst: [String] = []
        while let word = words.pop() {
            newestFirst.append(word)
        }
        return newestFirst.reversed().joined(separator: " ")
    }
}
