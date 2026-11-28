// Generated from src/dsa/content/lessons/divide-conquer/dc-inversions-majority.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Count inversions while merge sorting. Returns the count; sorts items[low..<high] as a side effect.
func sortAndCount(_ items: inout [Int], _ buffer: inout [Int], _ low: Int, _ high: Int) -> Int {
    guard high - low > 1 else { return 0 }
    let mid = low + (high - low) / 2
    let inLeft = sortAndCount(&items, &buffer, low, mid)
    let inRight = sortAndCount(&items, &buffer, mid, high)
    for index in low..<high {
        buffer[index] = items[index]
    }
    var across = 0
    var left = low
    var right = mid
    for write in low..<high {
        if right == high || (left < mid && buffer[left] <= buffer[right]) {
            items[write] = buffer[left]
            left += 1
        } else {
            items[write] = buffer[right]
            right += 1
            across += mid - left          // smaller than everything still waiting on the left
        }
    }
    if low == 0 && high == items.count {
        print("left half \(inLeft), right half \(inRight), across \(across)")
    }
    return inLeft + inRight + across
}

var items = [5, 2, 6, 1, 3, 4]
var buffer = items
let total = sortAndCount(&items, &buffer, 0, items.count)
print("total \(total), sorted \(items)")
