// Generated from src/dsa/content/lessons/elementary-sorts/sort-generic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func insertionSort<T: Comparable>(_ items: inout [T]) {
    guard items.count > 1 else { return }
    for i in 1..<items.count {
        let key = items[i]
        var gap = i
        while gap > 0 && items[gap - 1] > key {
            items[gap] = items[gap - 1]
            gap -= 1
        }
        items[gap] = key
    }
}

var numbers = [42, 7, 19, 3]
var words = ["pear", "apple", "fig"]
insertionSort(&numbers)
insertionSort(&words)
print(numbers)
print(words)
