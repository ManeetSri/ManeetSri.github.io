// Generated from src/dsa/content/lessons/heaps/heap-sort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Comparisons heap sort makes on 10,000 values in different starting orders
var comparisons = 0

func siftDown(_ items: inout [Int], from index: Int, end: Int) {
    var parent = index
    while true {
        let left = 2 * parent + 1
        let right = left + 1
        var largest = parent
        if left < end {
            comparisons += 1
            if items[left] > items[largest] { largest = left }
        }
        if right < end {
            comparisons += 1
            if items[right] > items[largest] { largest = right }
        }
        if largest == parent { return }
        items.swapAt(parent, largest)
        parent = largest
    }
}

func heapSort(_ items: inout [Int]) {
    for index in stride(from: items.count / 2 - 1, through: 0, by: -1) {
        siftDown(&items, from: index, end: items.count)
    }
    var end = items.count - 1
    while end > 0 {
        items.swapAt(0, end)
        siftDown(&items, from: 0, end: end)
        end -= 1
    }
}

let n = 10_000
let inputs = [
    ("already sorted", Array(0..<n)),
    ("reversed", Array((0..<n).reversed())),
    ("scrambled", (0..<n).map { ($0 * 7_919) % n }),
    ("all equal", Array(repeating: 7, count: n)),
]
for (name, values) in inputs {
    var items = values
    comparisons = 0
    heapSort(&items)
    print("\(name): \(comparisons) comparisons, sorted: \(items == values.sorted())")
}
