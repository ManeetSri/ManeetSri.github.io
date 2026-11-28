// Problem: Walking a buffer with pointers (M11 · Unsafe pointers, enough to recognise them)

public enum BufferPointerWalk {
    /// The sum of `numbers`, read through `withUnsafeBufferPointer`.
    public static func sum(_ numbers: [Int]) -> Int {
        // Write your solution here, then run:
        // swift test --filter BufferPointerWalkTests
        return 0
    }

    /// Reverses `numbers` in place, through `withUnsafeMutableBufferPointer`.
    public static func reverseInPlace(_ numbers: inout [Int]) {
    }

    /// The elements at indices 0, step, 2 × step, ..., read through the buffer's `baseAddress`
    /// with pointer arithmetic. `step` is at least 1.
    public static func sample(_ numbers: [Int], every step: Int) -> [Int] {
        return []
    }
}
