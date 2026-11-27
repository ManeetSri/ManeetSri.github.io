// Reference solution: Numbers in both lists.
// Turn both arrays into sets, intersect them, then sort the (small) result.
// O(n + m + k log k) time, where k is the number of common values; O(n + m) extra space.

public enum SortedCommon {
    public static func common(_ first: [Int], _ second: [Int]) -> [Int] {
        Set(first).intersection(second).sorted()
    }
}
