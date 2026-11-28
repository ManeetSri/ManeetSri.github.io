// Reference solution: The k smallest, in place. The first k passes of selection sort: each pass
// finds the smallest value in the unsorted part and swaps it to the front of that part, where it
// stays for good. O(n · k) time, O(1) extra space.

public enum PartialSelectionSort {
    public static func sortFirst(_ numbers: inout [Int], count k: Int) {
        let passes = min(k, numbers.count)
        for i in 0..<passes {
            var smallest = i
            for j in (i + 1)..<numbers.count where numbers[j] < numbers[smallest] {
                smallest = j
            }
            if smallest != i {
                numbers.swapAt(i, smallest)
            }
        }
    }
}
