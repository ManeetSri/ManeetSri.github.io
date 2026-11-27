// Reference solution: Sort a nearly sorted array. Plain insertion sort. Its cost is O(n + d) for d
// inversions, and when every value is at most k places from home, a key can only be shifted past
// bigger values that started fewer than 2k places to its left. So d < 2nk, and the sort is
// O(n · k) time with O(1) extra space. It doesn't even need to know k.

public enum NearlySortedArray {
    public static func sort(_ numbers: inout [Int], maxDistance k: Int) {
        guard numbers.count > 1 else { return }
        for i in 1..<numbers.count {
            let key = numbers[i]
            var gap = i
            while gap > 0 && numbers[gap - 1] > key {
                numbers[gap] = numbers[gap - 1]
                gap -= 1
            }
            numbers[gap] = key
        }
    }
}
