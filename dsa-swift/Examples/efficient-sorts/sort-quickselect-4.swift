// Generated from src/dsa/content/lessons/efficient-sorts/sort-quickselect.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The k smallest values, in no particular order: quickselect for index k - 1, then take the prefix
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 4)

func partition(_ items: inout [Int], _ low: Int, _ high: Int) -> Int {
    items.swapAt(dice.roll(low...high), high)
    let pivot = items[high]
    var boundary = low
    for j in low..<high where items[j] < pivot {
        items.swapAt(boundary, j)
        boundary += 1
    }
    items.swapAt(boundary, high)
    return boundary
}

/// Rearranges items so the value that belongs at index k is there, with smaller-or-equal values before it
func select(_ items: inout [Int], _ k: Int) {
    var low = 0
    var high = items.count - 1
    while low < high {
        let p = partition(&items, low, high)
        if p == k { return }
        if k < p { high = p - 1 } else { low = p + 1 }
    }
}

func smallest(_ k: Int, of numbers: [Int]) -> [Int] {
    guard k > 0 else { return [] }
    var items = numbers
    select(&items, k - 1)
    return Array(items[..<k])
}

let responseTimes = [120, 35, 410, 88, 52, 230, 61, 97, 300, 44]
let fastest = smallest(4, of: responseTimes)
print(fastest)
print(fastest.sorted())
