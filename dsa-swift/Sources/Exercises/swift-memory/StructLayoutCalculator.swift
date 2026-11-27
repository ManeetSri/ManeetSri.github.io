// Problem: Struct layout calculator (M11 · MemoryLayout: size, stride and alignment)

public enum StructLayoutCalculator {
    /// One stored property: how many bytes it uses and the alignment its offset must be a multiple of.
    public struct Field: Equatable {
        public let size: Int
        public let alignment: Int

        public init(size: Int, alignment: Int) {
            self.size = size
            self.alignment = alignment
        }
    }

    /// What MemoryLayout would report for the whole struct.
    public struct Layout: Equatable {
        public let size: Int
        public let stride: Int
        public let alignment: Int

        public init(size: Int, stride: Int, alignment: Int) {
            self.size = size
            self.stride = stride
            self.alignment = alignment
        }
    }

    /// The byte offset of each field when they're laid out in order, as Swift lays out a struct.
    public static func offsets(of fields: [Field]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter StructLayoutCalculatorTests
        return []
    }

    /// The size, stride and alignment of a struct with these fields, in this order.
    public static func layout(of fields: [Field]) -> Layout {
        return Layout(size: 0, stride: 0, alignment: 0)
    }
}
