// Generated from src/dsa/content/lessons/elementary-sorts/sort-selection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func selectionSort(_ items: inout [Int]) {
    guard items.count > 1 else { return }
    for i in 0..<(items.count - 1) {
        var smallest = i
        for j in (i + 1)..<items.count where items[j] < items[smallest] {
            smallest = j
        }
        if smallest != i {
            items.swapAt(i, smallest)
        }
        print("pass \(i + 1): smallest is \(items[i]) ->", items)
    }
}

var numbers = [29, 10, 14, 37, 13, 5]
selectionSort(&numbers)
