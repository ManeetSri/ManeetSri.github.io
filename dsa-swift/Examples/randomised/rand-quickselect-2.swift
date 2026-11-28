// Generated from src/dsa/content/lessons/randomised/rand-quickselect.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// How much do runs vary? 200 runs of quickselect for the median of 5,000 values
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 67)

func comparisons(_ numbers: [Int], _ k: Int) -> (comparisons: Int, partitions: Int) {
    var items = numbers
    var low = 0
    var high = items.count - 1
    var count = 0
    var partitions = 0
    while true {
        partitions += 1
        items.swapAt(dice.roll(low...high), high)
        let pivot = items[high]
        var boundary = low
        for j in low..<high {
            count += 1
            if items[j] < pivot {
                items.swapAt(boundary, j)
                boundary += 1
            }
        }
        items.swapAt(boundary, high)
        if boundary == k { return (count, partitions) }
        if k < boundary { high = boundary - 1 } else { low = boundary + 1 }
    }
}

let n = 5_000
let numbers = (0..<n).map { ($0 * 7_919) % n }
var results: [Int] = []
var partitionTotal = 0
for _ in 0..<200 {
    let run = comparisons(numbers, n / 2)
    results.append(run.comparisons)
    partitionTotal += run.partitions
}
let average = results.reduce(0, +) / results.count
print("fewest \(results.min()!), average \(average), most \(results.max()!)")
print("runs over 1.5 × average: \(results.filter { 2 * $0 > 3 * average }.count) of \(results.count)")
print("partitions per run on average: \(partitionTotal / results.count)")
