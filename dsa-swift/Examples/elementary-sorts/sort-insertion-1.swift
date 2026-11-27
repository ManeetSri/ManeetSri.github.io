// Generated from src/dsa/content/lessons/elementary-sorts/sort-insertion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func insertionSort(_ items: inout [Int]) {
    guard items.count > 1 else { return }
    for i in 1..<items.count {
        let key = items[i]
        var gap = i
        while gap > 0 && items[gap - 1] > key {
            items[gap] = items[gap - 1]       // shift the bigger value one place right
            gap -= 1
        }
        items[gap] = key                      // drop the key into the gap
        print("insert \(key) ->", items)
    }
}

var numbers = [12, 11, 13, 5, 6, 7]
insertionSort(&numbers)
