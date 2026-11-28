// Generated from src/dsa/content/lessons/complexity/bigo-cases.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func comparisonsToSort(_ numbers: [Int]) -> Int {
    var comparisons = 0
    _ = numbers.sorted { a, b in
        comparisons += 1
        return a < b
    }
    return comparisons
}

let n = 1_000
let ascending = Array(0..<n)
let descending = Array(ascending.reversed())
let mixed = (0..<n).map { ($0 * 7_919) % n }
print("already sorted:", comparisonsToSort(ascending))
print("reversed:", comparisonsToSort(descending))
print("mixed:", comparisonsToSort(mixed))
