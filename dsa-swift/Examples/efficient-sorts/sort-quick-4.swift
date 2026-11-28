// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Swaps made by Lomuto and Hoare partitioning while quick sorting the same input
var swaps = 0

func lomutoPartition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    let pivot = items[high]
    var boundary = low
    for j in low..<high where items[j] < pivot {
        items.swapAt(boundary, j)
        swaps += 1
        boundary += 1
    }
    items.swapAt(boundary, high)
    swaps += 1
    return boundary
}

func hoarePartition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    let pivot = items[low + (high - low) / 2]
    var i = low - 1
    var j = high + 1
    while true {
        repeat { i += 1 } while items[i] < pivot
        repeat { j -= 1 } while items[j] > pivot
        if i >= j { return j }
        items.swapAt(i, j)
        swaps += 1
    }
}

func lomutoSort(_ items: inout [Int], _ low: Int, _ high: Int) {
    guard low < high else { return }
    let p = lomutoPartition(&items, low, high)
    lomutoSort(&items, low, p - 1)
    lomutoSort(&items, p + 1, high)
}

func hoareSort(_ items: inout [Int], _ low: Int, _ high: Int) {
    guard low < high else { return }
    let split = hoarePartition(&items, low, high)
    hoareSort(&items, low, split)
    hoareSort(&items, split + 1, high)
}

let mixed = (0..<10_000).map { ($0 * 7_919) % 10_000 }
var a = mixed
swaps = 0
lomutoSort(&a, 0, a.count - 1)
print("Lomuto: \(swaps) swaps")
var b = mixed
swaps = 0
hoareSort(&b, 0, b.count - 1)
print("Hoare: \(swaps) swaps")
print(a == b, a == mixed.sorted())
