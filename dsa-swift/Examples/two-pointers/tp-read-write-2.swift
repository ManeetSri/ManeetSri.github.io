// Generated from src/dsa/content/lessons/two-pointers/tp-read-write.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func removeUnordered(_ value: Int, from items: inout [Int]) -> Int {
    var left = 0
    var right = items.count            // items[right...] is the discarded tail
    while left < right {
        if items[left] == value {
            right -= 1
            items[left] = items[right] // fill the hole; check this slot again next pass
        } else {
            left += 1
        }
    }
    return right
}

var items = [3, 1, 3, 2, 3, 4]
let kept = removeUnordered(3, from: &items)
print(kept, Array(items[..<kept]))
