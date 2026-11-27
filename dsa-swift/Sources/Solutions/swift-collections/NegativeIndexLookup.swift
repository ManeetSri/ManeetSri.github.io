// Reference solution: Count from the end. A negative position becomes `count + position`,
// then one bounds check covers both directions. O(1) time and space.

public enum NegativeIndexLookup {
    public static func element(in numbers: [Int], at position: Int) -> Int? {
        let index = position < 0 ? numbers.count + position : position
        guard numbers.indices.contains(index) else { return nil }
        return numbers[index]
    }
}
