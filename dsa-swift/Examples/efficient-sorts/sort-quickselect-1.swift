// Generated from src/dsa/content/lessons/efficient-sorts/sort-quickselect.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 11)

func partition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    items.swapAt(dice.roll(low...high), high)    // a random pivot, moved to the end
    let pivot = items[high]
    var boundary = low
    for j in low..<high where items[j] < pivot {
        items.swapAt(boundary, j)
        boundary += 1
    }
    items.swapAt(boundary, high)
    return boundary
}

/// The value that would be at index k (0-based) if numbers were sorted
func quickselect(_ numbers: [Int], _ k: Int) -> Int {
    var items = numbers
    var low = 0
    var high = items.count - 1
    while true {
        let p = partition(&items, low, high)
        print("range \(low)...\(high): pivot \(items[p]) lands at index \(p)")
        if p == k {
            return items[p]
        } else if k < p {
            high = p - 1                     // the answer is on the left: forget the right
        } else {
            low = p + 1                      // the answer is on the right: forget the left
        }
    }
}

let numbers = [42, 7, 19, 88, 3, 56, 23, 71, 12, 64]
print("median:", quickselect(numbers, numbers.count / 2))
print(numbers.sorted())
