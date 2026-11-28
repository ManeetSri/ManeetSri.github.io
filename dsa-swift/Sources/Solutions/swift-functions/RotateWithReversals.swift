// Reference solution: Rotate in place. Three reversals: O(n) time, O(1) extra space.

public enum RotateWithReversals {
    public static func rotateRight(_ numbers: inout [Int], by k: Int) {
        let count = numbers.count
        guard count > 1 else { return }
        let steps = k % count
        guard steps > 0 else { return }

        // Reverses numbers[start...end] in place
        func reverse(from start: Int, to end: Int) {
            var left = start
            var right = end
            while left < right {
                numbers.swapAt(left, right)
                left += 1
                right -= 1
            }
        }

        reverse(from: 0, to: count - 1)       // the last `steps` elements are now at the front, backwards
        reverse(from: 0, to: steps - 1)       // put them back in order
        reverse(from: steps, to: count - 1)   // and the rest too
    }
}
