// Generated from src/dsa/content/lessons/efficient-sorts/sort-shell-timsort.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// A bad input for halving gaps: small values at odd positions, large values at even positions
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

let n = 4_096
let interleaved = (0..<n).map { $0 % 2 == 0 ? n / 2 + $0 / 2 : $0 / 2 }
print(interleaved.prefix(8))

let halving = Array(sequence(first: n / 2) { $0 > 1 ? $0 / 2 : nil })
var knuth = [1]
while knuth.last! * 3 + 1 < n { knuth.append(knuth.last! * 3 + 1) }
print("halving:", shellSortComparisons(interleaved, gaps: halving))
print("3k + 1:", shellSortComparisons(interleaved, gaps: knuth.reversed()))
