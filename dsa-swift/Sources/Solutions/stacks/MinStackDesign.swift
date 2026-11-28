// Reference solution: Min stack. Each entry stores its value and the minimum of everything at or
// below it. The top entry's minimum is the whole stack's minimum, and popping restores the previous
// minimum automatically, because the entry underneath remembers it. O(1) per operation, O(n) space.

public enum MinStackDesign {
    public struct MinStack {
        private var entries: [(value: Int, minimum: Int)] = []

        public init() {}

        public mutating func push(_ value: Int) {
            let minimum = Swift.min(value, entries.last?.minimum ?? value)
            entries.append((value, minimum))
        }

        @discardableResult
        public mutating func pop() -> Int? {
            entries.popLast()?.value
        }

        public var top: Int? {
            entries.last?.value
        }

        public var minimum: Int? {
            entries.last?.minimum
        }

        public var count: Int {
            entries.count
        }
    }
}
