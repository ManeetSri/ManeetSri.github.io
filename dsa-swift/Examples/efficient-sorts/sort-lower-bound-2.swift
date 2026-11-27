// Generated from src/dsa/content/lessons/efficient-sorts/sort-lower-bound.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

import Foundation

// The fewest comparisons any comparison sort can promise in the worst case, ⌈log₂ n!⌉,
// next to merge sort's actual worst case and n log₂ n
func lowerBound(_ n: Int) -> Int {
    var total = 0.0
    for i in 2...n {
        total += log2(Double(i))             // log₂ n! = log₂ 2 + log₂ 3 + … + log₂ n
    }
    return Int(total.rounded(.up))
}

/// Merge sort's worst case: sort both halves, then merge with up to n - 1 comparisons
func mergeSortWorst(_ n: Int) -> Int {
    n <= 1 ? 0 : mergeSortWorst(n / 2) + mergeSortWorst(n - n / 2) + n - 1
}

for n in [3, 10, 100, 1_000, 1_000_000] {
    let nLogN = Int((Double(n) * log2(Double(n))).rounded())
    print("n = \(n): at least \(lowerBound(n)), merge sort at most \(mergeSortWorst(n)), n log₂ n ≈ \(nLogN)")
}
