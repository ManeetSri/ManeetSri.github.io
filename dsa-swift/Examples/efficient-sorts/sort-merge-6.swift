// Generated from src/dsa/content/lessons/efficient-sorts/sort-merge.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Bottom-up merge sort: merge runs of width 1, then 2, then 4, … until one run covers everything
func mergeSortBottomUp(_ items: inout [Int]) {
    let n = items.count
    var buffer = items
    var width = 1
    while width < n {
        for low in stride(from: 0, to: n, by: 2 * width) {
            let mid = min(low + width, n)            // the last pair can be short…
            let high = min(low + 2 * width, n)       // …or have no right run at all
            for index in low..<high {
                buffer[index] = items[index]
            }
            var left = low
            var right = mid
            for write in low..<high {
                if right == high || (left < mid && buffer[left] <= buffer[right]) {
                    items[write] = buffer[left]
                    left += 1
                } else {
                    items[write] = buffer[right]
                    right += 1
                }
            }
        }
        print("width \(width): \(items)")
        width *= 2
    }
}

var numbers = [38, 27, 43, 3, 9, 82, 10]
mergeSortBottomUp(&numbers)
