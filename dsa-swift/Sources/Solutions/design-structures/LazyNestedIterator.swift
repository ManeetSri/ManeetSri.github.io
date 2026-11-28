// Reference solution: Lazy nested-list iterator. A stack of (list, position) frames replaces the
// recursion an eager flatten would use. `settle()` pops finished lists and steps into nested ones
// until the top frame points at a number, so `peek()` can look at it without consuming it.
// `init` is O(1); a full pass is O(total items, counting every list), and memory is O(depth).

public enum LazyNestedIterator {
    public enum Item: Equatable {
        case number(Int)
        case list([Item])
    }

    public struct Flattener: IteratorProtocol, Sequence {
        /// One frame per list being walked: the list and the position of its next unvisited item.
        private var frames: [(items: [Item], position: Int)]

        public init(_ items: [Item]) {
            frames = [(items, 0)]
        }

        /// Leaves the top frame pointing at a number, or empties the stack if no numbers are left.
        private mutating func settle() {
            while let top = frames.last {
                if top.position == top.items.count {
                    frames.removeLast()                         // this list is finished
                    continue
                }
                switch top.items[top.position] {
                case .number:
                    return
                case .list(let inner):
                    frames[frames.count - 1].position += 1      // step past the list in its parent,
                    frames.append((inner, 0))                   // then into it
                }
            }
        }

        public mutating func peek() -> Int? {
            settle()
            guard let top = frames.last, case .number(let value) = top.items[top.position] else {
                return nil
            }
            return value
        }

        public mutating func next() -> Int? {
            guard let value = peek() else { return nil }
            frames[frames.count - 1].position += 1              // consume it
            return value
        }
    }
}
