// Reference solution: First and last position of a value. Two binary searches for "the first index
// where a condition becomes true": the lower bound (first value ≥ target) and the upper bound (first
// value > target). If the lower bound holds the target, the run of copies is lower...upper - 1.
// O(log n) time however long the run is, O(1) space.

public enum FirstLastPosition {
    public static func span(of target: Int, in numbers: [Int]) -> ClosedRange<Int>? {
        let first = firstIndex(in: numbers) { $0 >= target }
        guard first < numbers.count, numbers[first] == target else { return nil }
        let pastLast = firstIndex(in: numbers) { $0 > target }
        return first...(pastLast - 1)
    }

    /// The first index whose value makes `isTrue` return true, or `numbers.count` if none does.
    /// The values must give false, …, false, true, …, true.
    private static func firstIndex(in numbers: [Int], where isTrue: (Int) -> Bool) -> Int {
        var low = 0
        var high = numbers.count                 // half-open: the answer is in [low, high]
        while low < high {
            let mid = low + (high - low) / 2
            if isTrue(numbers[mid]) {
                high = mid                       // mid could be the first true: keep it
            } else {
                low = mid + 1
            }
        }
        return low
    }
}
