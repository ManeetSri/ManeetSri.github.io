// Problem: Build a dynamic array (M18 · Build your own DynamicArray)

public enum BuildDynamicArray {
    /// A growable array that keeps its elements in a fixed-size buffer of optionals and doubles the
    /// buffer whenever it's full. A new array has capacity 0; the first append grows it to 1.
    public struct DynamicArray<Element> {
        // Write your solution here, then run:
        // swift test --filter BuildDynamicArrayTests
        // The buffer's size is the capacity. Never call buffer.append: allocate a bigger buffer
        // yourself when it's full. Add any other stored properties you need.
        private var buffer: [Element?] = []

        /// Creates an empty array with capacity 0.
        public init() {}

        /// How many elements the array holds.
        public var count: Int {
            return 0
        }

        /// How many elements fit before the buffer has to grow.
        public var capacity: Int {
            return 0
        }

        /// True when the array holds no elements.
        public var isEmpty: Bool {
            return true
        }

        /// Adds `element` at the end, doubling the capacity first if the buffer is full
        /// (from 0, grow to 1). Amortised O(1).
        public mutating func append(_ element: Element) {
        }

        /// Inserts `element` at `index` (0...count), shifting later elements right. O(n).
        public mutating func insert(_ element: Element, at index: Int) {
        }

        /// Removes and returns the element at `index` (0..<count), shifting later elements left.
        /// The capacity stays the same. O(n).
        public mutating func remove(at index: Int) -> Element {
            return buffer[index]!   // placeholder so the stub compiles: replace it
        }

        /// Removes and returns the last element, or nil if the array is empty. O(1).
        public mutating func popLast() -> Element? {
            return nil
        }

        /// Reads or writes the element at `index`, which must be in 0..<count. O(1).
        public subscript(index: Int) -> Element {
            get {
                return buffer[index]!   // placeholder so the stub compiles: replace it
            }
            set {
            }
        }
    }
}
