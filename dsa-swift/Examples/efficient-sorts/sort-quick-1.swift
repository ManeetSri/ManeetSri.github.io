// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Lomuto partition: the pivot is the last element of items[low...high]
func lomutoPartition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    let pivot = items[high]
    var boundary = low                       // low..<boundary: smaller than the pivot
    for j in low..<high {
        if items[j] < pivot {
            items.swapAt(boundary, j)
            boundary += 1
        }
    }
    items.swapAt(boundary, high)             // the pivot goes between the two sides
    return boundary
}

var numbers = [7, 2, 9, 4, 3, 8, 5]
let p = lomutoPartition(&numbers, 0, numbers.count - 1)
print(numbers, "pivot at index \(p)")
print("smaller:", numbers[..<p], "bigger or equal:", numbers[(p + 1)...])
