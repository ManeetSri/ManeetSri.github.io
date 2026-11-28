// Reference solution: Fewest swaps to sort. Run cyclic sort on a copy and count its swaps. Each swap
// sends one value home for good, and a cycle of length L needs L − 1 swaps, so it makes n minus the
// number of cycles swaps, which is the minimum: one swap can split a cycle into at most two.
// O(n) time, O(n) space for the copy.

public enum FewestSwapsToSort {
    public static func fewestSwaps(_ numbers: [Int]) -> Int {
        var items = numbers
        var swaps = 0
        var i = 0
        while i < items.count {
            let home = items[i] - 1
            if home != i {                                // values are distinct, so this is safe
                items.swapAt(i, home)
                swaps += 1
            } else {
                i += 1
            }
        }
        return swaps
    }
}
