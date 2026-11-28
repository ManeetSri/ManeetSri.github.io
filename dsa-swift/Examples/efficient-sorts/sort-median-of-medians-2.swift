// Generated from src/dsa/content/lessons/efficient-sorts/sort-median-of-medians.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Comparisons per element: median of medians against random-pivot quickselect
struct Dice {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func roll(_ range: Range<Int>) -> Int {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return range.lowerBound + Int((state >> 33) % UInt64(range.count))
    }
}

var dice = Dice(seed: 2)
var comparisons = 0

func isLess(_ a: Int, _ b: Int) -> Bool {
    comparisons += 1
    return a < b
}

/// Splits numbers three ways around pivot
func split(_ numbers: [Int], around pivot: Int) -> (smaller: [Int], equal: Int, larger: [Int]) {
    var smaller: [Int] = []
    var larger: [Int] = []
    for value in numbers {
        if isLess(value, pivot) {
            smaller.append(value)
        } else if isLess(pivot, value) {
            larger.append(value)
        }
    }
    return (smaller, numbers.count - smaller.count - larger.count, larger)
}

func medianOfMedians(_ numbers: [Int], _ k: Int) -> Int {
    if numbers.count <= 5 {
        return numbers.sorted(by: isLess)[k]
    }
    var medians: [Int] = []
    for start in stride(from: 0, to: numbers.count, by: 5) {
        let group = numbers[start..<min(start + 5, numbers.count)].sorted(by: isLess)
        medians.append(group[group.count / 2])
    }
    let pivot = medianOfMedians(medians, medians.count / 2)
    let parts = split(numbers, around: pivot)
    if k < parts.smaller.count { return medianOfMedians(parts.smaller, k) }
    if k < parts.smaller.count + parts.equal { return pivot }
    return medianOfMedians(parts.larger, k - parts.smaller.count - parts.equal)
}

func randomSelect(_ numbers: [Int], _ k: Int) -> Int {
    let pivot = numbers[dice.roll(0..<numbers.count)]
    let parts = split(numbers, around: pivot)
    if k < parts.smaller.count { return randomSelect(parts.smaller, k) }
    if k < parts.smaller.count + parts.equal { return pivot }
    return randomSelect(parts.larger, k - parts.smaller.count - parts.equal)
}

func perElement(_ n: Int) -> String {
    let tenths = comparisons * 10 / n
    return "\(tenths / 10).\(tenths % 10)"
}

var data = Dice(seed: 99)
for n in [1_000, 10_000, 100_000] {
    let numbers = (0..<n).map { _ in data.roll(0..<1_000_000) }
    comparisons = 0
    let a = medianOfMedians(numbers, n / 2)
    let guaranteed = perElement(n)
    comparisons = 0
    let b = randomSelect(numbers, n / 2)
    print("n = \(n): median of medians \(guaranteed), random pivot \(perElement(n)) comparisons per element (same answer: \(a == b))")
}
