// Reference solution: Walking a buffer with pointers. Each function borrows the array's memory only
// inside the closure and returns plain values, so no pointer escapes. Each is O(n) time, O(1) extra space
// (apart from the sampled result).

public enum BufferPointerWalk {
    public static func sum(_ numbers: [Int]) -> Int {
        numbers.withUnsafeBufferPointer { buffer in
            var total = 0
            for value in buffer {
                total += value
            }
            return total
        }
    }

    // Two indices move towards each other, swapping as they go
    public static func reverseInPlace(_ numbers: inout [Int]) {
        numbers.withUnsafeMutableBufferPointer { buffer in
            var left = 0
            var right = buffer.count - 1
            while left < right {
                buffer.swapAt(left, right)
                left += 1
                right -= 1
            }
        }
    }

    // base + i moves i elements forward, so stepping the offset by `step` visits every step-th element
    public static func sample(_ numbers: [Int], every step: Int) -> [Int] {
        numbers.withUnsafeBufferPointer { buffer in
            guard let base = buffer.baseAddress else {
                return []
            }
            var picked: [Int] = []
            var offset = 0
            while offset < buffer.count {
                picked.append((base + offset).pointee)
                offset += step
            }
            return picked
        }
    }
}
