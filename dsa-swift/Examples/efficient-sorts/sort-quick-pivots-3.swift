// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick-pivots.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Three-way partition around pivot: the Dutch national flag with "less", "equal" and "greater"
func partition3(_ items: inout [Int], _ low: Int, _ high: Int, pivot: Int) -> (lessEnd: Int, greaterStart: Int) {
    var less = low                           // low..<less: smaller than the pivot
    var scan = low                           // less..<scan: equal to it
    var greater = high + 1                   // scan..<greater: not looked at yet
    while scan < greater {                   // greater...high: larger than it
        if items[scan] < pivot {
            items.swapAt(less, scan)
            less += 1
            scan += 1
        } else if items[scan] > pivot {
            greater -= 1
            items.swapAt(scan, greater)      // the element swapped in hasn't been looked at
        } else {
            scan += 1
        }
    }
    return (less, greater)
}

var numbers = [4, 9, 4, 1, 4, 7, 2, 4]
let (lessEnd, greaterStart) = partition3(&numbers, 0, numbers.count - 1, pivot: 4)
print(numbers)
print("smaller:", numbers[..<lessEnd], "equal:", numbers[lessEnd..<greaterStart], "larger:", numbers[greaterStart...])
