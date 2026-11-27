// Reference solution: Heap sort in place. Heapify the whole array into a max-heap bottom-up (O(n)).
// Then n - 1 times, swap the largest value (the root) to the end of the heap region, shrink the region
// by one, and sift the new root down (O(log n)). O(n log n) in every case, O(1) extra space.

public enum InPlaceHeapSort {
    public static func sort(_ items: inout [Int]) {
        let count = items.count
        for index in stride(from: count / 2 - 1, through: 0, by: -1) {
            siftDown(&items, from: index, end: count)
        }
        var end = count - 1
        while end > 0 {
            items.swapAt(0, end)                         // the largest left joins the sorted suffix
            siftDown(&items, from: 0, end: end)
            end -= 1
        }
    }

    /// Sifts items[index] down a max-heap that occupies items[0..<end].
    private static func siftDown(_ items: inout [Int], from index: Int, end: Int) {
        var parent = index
        while true {
            let left = 2 * parent + 1
            let right = left + 1
            var largest = parent
            if left < end && items[left] > items[largest] { largest = left }
            if right < end && items[right] > items[largest] { largest = right }
            if largest == parent { return }
            items.swapAt(parent, largest)
            parent = largest
        }
    }
}
