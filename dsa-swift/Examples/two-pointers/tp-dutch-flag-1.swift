// Generated from src/dsa/content/lessons/two-pointers/tp-dutch-flag.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sortColours(_ items: inout [Int]) {
    var low = 0
    var mid = 0
    var high = items.count - 1
    while mid <= high {
        if items[mid] == 0 {
            items.swapAt(low, mid)
            low += 1
            mid += 1
        } else if items[mid] == 1 {
            mid += 1
        } else {
            items.swapAt(mid, high)
            high -= 1
        }
    }
}

var a = [2, 0, 2, 1, 1, 0, 1, 2, 0]
sortColours(&a)
print(a)

var b = [2, 2, 0]
sortColours(&b)
print(b)

var c: [Int] = []
sortColours(&c)
print(c)
