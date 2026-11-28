// Reference solution: Kth largest value. Quickselect. The kth largest of n values is the one at
// index n - k in increasing order. Partition three ways around a random pivot (smaller, equal,
// larger), then keep only the part that holds that index; if it falls among the copies of the
// pivot, the pivot is the answer. Random pivots make every input O(n) expected, and the equal block
// stops duplicates from slowing it down. O(n) extra space for the working copy.

public enum KthLargestValue {
    public static func kthLargest(in numbers: [Int], k: Int) -> Int {
        var items = numbers
        let target = items.count - k                     // its index in increasing order
        var low = 0
        var high = items.count                           // the answer is somewhere in low..<high
        while true {
            let pivot = items[Int.random(in: low..<high)]
            var less = low                               // low..<less: smaller than the pivot
            var scan = low                               // less..<scan: equal to it
            var greater = high                           // greater..<high: larger than it
            while scan < greater {
                if items[scan] < pivot {
                    items.swapAt(less, scan)
                    less += 1
                    scan += 1
                } else if items[scan] > pivot {
                    greater -= 1
                    items.swapAt(scan, greater)
                } else {
                    scan += 1
                }
            }
            if target < less {
                high = less
            } else if target >= greater {
                low = greater
            } else {
                return pivot
            }
        }
    }
}
