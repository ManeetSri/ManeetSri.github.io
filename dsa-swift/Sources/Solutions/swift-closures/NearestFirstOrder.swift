// Reference solution: Closest to the target first. sorted(by:) with a trailing closure that
// compares distances, then values. O(n log n) time, O(n) space for the new array.

public enum NearestFirstOrder {
    public static func sorted(_ numbers: [Int], around target: Int) -> [Int] {
        numbers.sorted { first, second in
            let firstDistance = abs(first - target)
            let secondDistance = abs(second - target)
            if firstDistance != secondDistance {
                return firstDistance < secondDistance
            }
            return first < second
        }
    }
}
