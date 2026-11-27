// Generated from src/dsa/content/lessons/efficient-sorts/sort-shell-timsort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Shell sort: insertion sort on elements gap apart, for shrinking gaps that end with 1
func shellSort(_ items: inout [Int], gaps: [Int]) {
    for gap in gaps where gap < items.count {
        for next in gap..<items.count {
            let value = items[next]
            var slot = next
            while slot >= gap && items[slot - gap] > value {
                items[slot] = items[slot - gap]      // shift the bigger element gap places right
                slot -= gap
            }
            items[slot] = value
        }
        print("gap \(gap): \(items)")
    }
}

var numbers = [62, 83, 18, 53, 7, 17, 95, 86, 47, 69, 25, 28]
shellSort(&numbers, gaps: [4, 1])
