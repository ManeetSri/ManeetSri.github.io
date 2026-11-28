// Problem: Parallel merge sort (M70 · Parallel merge sort and BFS with TaskGroup)

public enum TaskGroupMergeSort {
    /// Merges two arrays that are each in increasing order into one array in increasing order.
    public static func merge(_ first: [Int], _ second: [Int]) -> [Int] {
        // Write your solution here, then run:
        // swift test --filter TaskGroupMergeSortTests
        return []
    }

    /// `items` in increasing order. An array of more than `threshold` elements is split in half, the
    /// two halves are sorted concurrently in child tasks (recursively, by this same function), and the
    /// results are merged; an array of `threshold` elements or fewer is sorted directly.
    /// `threshold` is at least 1.
    public static func sorted(_ items: [Int], threshold: Int) async -> [Int] {
        return []
    }
}
