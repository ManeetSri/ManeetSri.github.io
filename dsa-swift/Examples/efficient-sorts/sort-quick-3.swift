// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Hoare partition of items[low...high]. Returns a split index s: afterwards every element in
// low...s is ≤ pivot and every element in (s + 1)...high is ≥ pivot. The pivot needn't be at s.
func hoarePartition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    let pivot = items[low + (high - low) / 2]    // the middle element (rounding down)
    var i = low - 1
    var j = high + 1
    while true {
        repeat { i += 1 } while items[i] < pivot   // find an element that belongs on the right
        repeat { j -= 1 } while items[j] > pivot   // find an element that belongs on the left
        if i >= j { return j }                     // the scans have met: done
        items.swapAt(i, j)
    }
}

var numbers = [3, 9, 5, 1, 7, 2]
let split = hoarePartition(&numbers, 0, numbers.count - 1)
print(numbers, "split at \(split)")
print("left:", numbers[...split], "right:", numbers[(split + 1)...])
