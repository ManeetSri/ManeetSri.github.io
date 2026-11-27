// Generated from src/dsa/content/lessons/efficient-sorts/sort-quickselect.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The worst case: a fixed last-element pivot, looking for the smallest value of sorted input
var comparisons = 0

func partition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    let pivot = items[high]
    var boundary = low
    for j in low..<high {
        comparisons += 1
        if items[j] < pivot {
            items.swapAt(boundary, j)
            boundary += 1
        }
    }
    items.swapAt(boundary, high)
    return boundary
}

func quickselect(_ numbers: [Int], _ k: Int) -> Int {
    var items = numbers
    var low = 0
    var high = items.count - 1
    while true {
        let p = partition(&items, low, high)
        if p == k { return items[p] }
        if k < p { high = p - 1 } else { low = p + 1 }
    }
}

let n = 2_000
print(quickselect(Array(0..<n), 0), comparisons)
