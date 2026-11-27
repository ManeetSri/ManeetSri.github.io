// Generated from src/dsa/content/lessons/elementary-sorts/sort-bubble.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func bubbleSort(_ items: inout [Int]) {
    guard items.count > 1 else { return }
    for pass in 0..<(items.count - 1) {
        var swapped = false
        for j in 0..<(items.count - 1 - pass) {      // the last `pass` positions are final
            if items[j] > items[j + 1] {
                items.swapAt(j, j + 1)
                swapped = true
            }
        }
        print("after pass \(pass + 1):", items)
        if !swapped { return }                       // no swaps: already sorted
    }
}

var numbers = [5, 1, 4, 2, 8, 3]
bubbleSort(&numbers)
