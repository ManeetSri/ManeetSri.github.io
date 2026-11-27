// Generated from src/dsa/content/lessons/randomised/rand-quickselect.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// Expected comparisons of randomised quickselect: the pair formula against an average of real runs
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: ClosedRange<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 31)

/// Comparisons made by one run of quickselect (Lomuto, random pivot) looking for index k
func comparisons(_ numbers: [Int], _ k: Int) -> Int {
    var items = numbers
    var low = 0
    var high = items.count - 1
    var count = 0
    while true {
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
        if boundary == k { return count }
        if k < boundary { high = boundary - 1 } else { low = boundary + 1 }
    }
}

/// The exact expected count: ranks a < b are compared only if one of them is the first pivot chosen
/// from the span between min(a, target) and max(b, target)
func expected(n: Int, target: Int) -> Double {
    var total = 0.0
    for a in 0..<n {
        for b in (a + 1)..<n {
            let span = max(b, target) - min(a, target) + 1
            total += 2.0 / Double(span)
        }
    }
    return total
}

let n = 1_000
let numbers = (0..<n).map { ($0 * 7_919) % n }       // 0..<1000 in a scrambled order
for (name, target) in [("smallest", 0), ("median", n / 2)] {
    let runs = 400
    var sum = 0
    for _ in 0..<runs {
        sum += comparisons(numbers, target)
    }
    let average = Double(sum) / Double(runs)
    print(name + ":", String(format: "formula %.1f, average of %d runs %.1f", expected(n: n, target: target), runs, average))
}
print(String(format: "2n = %d, 2n(1 + ln 2) = %.1f", 2 * n, 2 * Double(n) * (1 + log(2.0))))
