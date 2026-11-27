import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

// Real structs, so the tests can compare against what Swift itself reports
private struct Padded { var flag: Bool; var count: Int; var done: Bool }
private struct Packed { var count: Int; var flag: Bool; var done: Bool }
private struct Mixed { var a: Int8; var b: Int16; var c: Int8; var d: Int64 }
private struct Pixel { var red: UInt8; var green: UInt8; var blue: UInt8 }
private struct Inner { var value: Int; var flag: Bool }
private struct Outer { var inner: Inner; var extra: Bool }
private struct Empty {}

@Suite struct StructLayoutCalculatorTests {
    typealias Field = StructLayoutCalculator.Field
    typealias Layout = StructLayoutCalculator.Layout

    private static let bool = Field(size: 1, alignment: 1)
    private static let int8 = Field(size: 1, alignment: 1)
    private static let int16 = Field(size: 2, alignment: 2)
    private static let int = Field(size: 8, alignment: 8)

    private func swiftLayout<T>(of type: T.Type) -> Layout {
        Layout(size: MemoryLayout<T>.size, stride: MemoryLayout<T>.stride, alignment: MemoryLayout<T>.alignment)
    }

    @Test("Padding before a wider field")
    func padded() {
        let fields = [Self.bool, Self.int, Self.bool]
        #expect(StructLayoutCalculator.offsets(of: fields) == [0, 8, 16])
        #expect(StructLayoutCalculator.layout(of: fields) == Layout(size: 17, stride: 24, alignment: 8))
        #expect(StructLayoutCalculator.layout(of: fields) == swiftLayout(of: Padded.self))
    }

    @Test("Widest field first packs tightly")
    func packed() {
        let fields = [Self.int, Self.bool, Self.bool]
        #expect(StructLayoutCalculator.offsets(of: fields) == [0, 8, 9])
        #expect(StructLayoutCalculator.layout(of: fields) == Layout(size: 10, stride: 16, alignment: 8))
        #expect(StructLayoutCalculator.layout(of: fields) == swiftLayout(of: Packed.self))
    }

    @Test("Mixed widths")
    func mixed() {
        let fields = [Self.int8, Self.int16, Self.int8, Self.int]
        #expect(StructLayoutCalculator.offsets(of: fields) == [0, 2, 4, 8])
        #expect(StructLayoutCalculator.layout(of: fields) == swiftLayout(of: Mixed.self))
    }

    @Test("All one-byte fields need no padding")
    func bytes() {
        let fields = [Self.int8, Self.int8, Self.int8]
        #expect(StructLayoutCalculator.offsets(of: fields) == [0, 1, 2])
        #expect(StructLayoutCalculator.layout(of: fields) == Layout(size: 3, stride: 3, alignment: 1))
        #expect(StructLayoutCalculator.layout(of: fields) == swiftLayout(of: Pixel.self))
    }

    @Test("A nested struct's tail padding is reused")
    func tailPadding() {
        let inner = Field(size: 9, alignment: 8)   // Inner: Int then Bool
        let fields = [inner, Self.bool]
        #expect(StructLayoutCalculator.offsets(of: fields) == [0, 9])
        #expect(StructLayoutCalculator.layout(of: fields) == Layout(size: 10, stride: 16, alignment: 8))
        #expect(StructLayoutCalculator.layout(of: fields) == swiftLayout(of: Outer.self))
    }

    @Test("A struct with no fields has size 0 but stride 1")
    func empty() {
        #expect(StructLayoutCalculator.offsets(of: []) == [])
        #expect(StructLayoutCalculator.layout(of: []) == Layout(size: 0, stride: 1, alignment: 1))
        #expect(StructLayoutCalculator.layout(of: []) == swiftLayout(of: Empty.self))
    }

    @Test("Zero-sized fields take no space", arguments: [
        ([Field(size: 0, alignment: 1)], Layout(size: 0, stride: 1, alignment: 1)),
        ([Field(size: 4, alignment: 4), Field(size: 0, alignment: 1)], Layout(size: 4, stride: 4, alignment: 4)),
    ])
    func zeroSized(fields: [Field], expected: Layout) {
        #expect(StructLayoutCalculator.layout(of: fields) == expected)
    }

    @Test("More layouts", arguments: [
        ([Field(size: 4, alignment: 4), Field(size: 1, alignment: 1), Field(size: 4, alignment: 4)], Layout(size: 12, stride: 12, alignment: 4)),
        ([Field(size: 4, alignment: 4), Field(size: 4, alignment: 4), Field(size: 1, alignment: 1)], Layout(size: 9, stride: 12, alignment: 4)),
        ([Field(size: 1, alignment: 1), Field(size: 8, alignment: 8)], Layout(size: 16, stride: 16, alignment: 8)),
        ([Field(size: 9, alignment: 8), Field(size: 9, alignment: 8)], Layout(size: 25, stride: 32, alignment: 8)),
        ([Field(size: 2, alignment: 2), Field(size: 1, alignment: 1)], Layout(size: 3, stride: 4, alignment: 2)),
        ([Field(size: 1, alignment: 1), Field(size: 16, alignment: 16)], Layout(size: 32, stride: 32, alignment: 16)),
    ])
    func moreLayouts(fields: [Field], expected: Layout) {
        #expect(StructLayoutCalculator.layout(of: fields) == expected)
    }

    @Test("Offsets match Swift's own")
    func offsetsMatchSwift() {
        let fields = [Self.int8, Self.int16, Self.int8, Self.int]
        let swiftOffsets = [
            MemoryLayout<Mixed>.offset(of: \.a)!,
            MemoryLayout<Mixed>.offset(of: \.b)!,
            MemoryLayout<Mixed>.offset(of: \.c)!,
            MemoryLayout<Mixed>.offset(of: \.d)!,
        ]
        #expect(StructLayoutCalculator.offsets(of: fields) == swiftOffsets)
    }
}
