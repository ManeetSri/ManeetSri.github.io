// Generated from src/dsa/content/lessons/efficient-sorts/sort-shell-timsort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Comparisons made by Shell sort with different gap sequences, on the same 5,000 numbers
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ limit: Int) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return Int((state >> 33) % UInt64(limit))
    }
}

func shellSortComparisons(_ numbers: [Int], gaps: [Int]) -> Int {
    var items = numbers
    var comparisons = 0
    for gap in gaps where gap < items.count {
        for next in gap..<items.count {
            let value = items[next]
            var slot = next
            while slot >= gap {
                comparisons += 1
                if items[slot - gap] <= value { break }
                items[slot] = items[slot - gap]
                slot -= gap
            }
            items[slot] = value
        }
    }
    return comparisons
}

let n = 5_000
var dice = Dice(seed: 1)
let numbers = (0..<n).map { _ in dice.roll(1_000_000) }

let halving = Array(sequence(first: n / 2) { $0 > 1 ? $0 / 2 : nil })     // 2500, 1250, …, 1
var knuth = [1]                                                            // 1, 4, 13, 40, …
while knuth.last! * 3 + 1 < n { knuth.append(knuth.last! * 3 + 1) }
let ciura = [1, 4, 10, 23, 57, 132, 301, 701, 1750]                       // found by experiment

print("gap 1 only (insertion sort):", shellSortComparisons(numbers, gaps: [1]))
print("halving (Shell, 1959):", shellSortComparisons(numbers, gaps: halving))
print("3k + 1 (Knuth):", shellSortComparisons(numbers, gaps: knuth.reversed()))
print("Ciura:", shellSortComparisons(numbers, gaps: ciura.reversed()))
