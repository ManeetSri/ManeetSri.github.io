// Reference solution: Struct layout calculator. Place each field at the next multiple of its alignment,
// then round the end up to the largest alignment for the stride. O(n) time, O(1) extra space for layout(of:).

public enum StructLayoutCalculator {
    public struct Field: Equatable {
        public let size: Int
        public let alignment: Int

        public init(size: Int, alignment: Int) {
            self.size = size
            self.alignment = alignment
        }
    }

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

    /// The smallest multiple of `alignment` that is at least `offset`.
    private static func roundUp(_ offset: Int, toMultipleOf alignment: Int) -> Int {
        (offset + alignment - 1) / alignment * alignment
    }

    public static func offsets(of fields: [Field]) -> [Int] {
        var offsets: [Int] = []
        var end = 0
        for field in fields {
            let start = roundUp(end, toMultipleOf: field.alignment)
            offsets.append(start)
            end = start + field.size
        }
        return offsets
    }

    public static func layout(of fields: [Field]) -> Layout {
        var end = 0
        var alignment = 1
        for field in fields {
            end = roundUp(end, toMultipleOf: field.alignment) + field.size
            alignment = max(alignment, field.alignment)
        }
        let stride = max(1, roundUp(end, toMultipleOf: alignment))
        return Layout(size: end, stride: stride, alignment: alignment)
    }
}
