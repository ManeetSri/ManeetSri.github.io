// Generated from src/dsa/content/lessons/divide-conquer/dc-paradigm.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var comparisons = 0

// Both answers from one pass: smallest first, then largest
func twoScans(_ numbers: [Int]) -> (smallest: Int, largest: Int) {
    var smallest = numbers[0]
    var largest = numbers[0]
    for value in numbers.dropFirst() {
        comparisons += 2
        if value < smallest { smallest = value }
        if value > largest { largest = value }
    }
    return (smallest, largest)
}

// Divide and conquer: a pair needs one comparison, and combining two answers needs two
func smallestAndLargest(_ numbers: [Int], _ low: Int, _ high: Int) -> (smallest: Int, largest: Int) {
    if high - low == 1 {
        return (numbers[low], numbers[low])
    }
    if high - low == 2 {
        comparisons += 1
        let (a, b) = (numbers[low], numbers[low + 1])
        return a < b ? (a, b) : (b, a)
    }
    let mid = low + (high - low) / 2
    let left = smallestAndLargest(numbers, low, mid)
    let right = smallestAndLargest(numbers, mid, high)
    comparisons += 2
    return (min(left.smallest, right.smallest), max(left.largest, right.largest))
}

for n in [16, 1_024, 1_000_000] {
    let numbers = (0..<n).map { ($0 * 7_919) % n }
    comparisons = 0
    let first = twoScans(numbers)
    let scanCount = comparisons
    comparisons = 0
    let second = smallestAndLargest(numbers, 0, n)
    print("n = \(n): \(first == second ? "same answer" : "different!"), two scans \(scanCount), divide and conquer \(comparisons)")
}
