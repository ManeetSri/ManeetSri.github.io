// Generated from src/dsa/content/lessons/efficient-sorts/sort-median-of-medians.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Median of medians: select the value for index k (0-based) in worst-case O(n)
var comparisons = 0

func isLess(_ a: Int, _ b: Int) -> Bool {
    comparisons += 1
    return a < b
}

func select(_ numbers: [Int], _ k: Int) -> Int {
    if numbers.count <= 5 {
        return numbers.sorted(by: isLess)[k]         // tiny: sort it directly
    }
    // 1. Split into groups of 5 and take the median of each group
    var medians: [Int] = []
    for start in stride(from: 0, to: numbers.count, by: 5) {
        let group = numbers[start..<min(start + 5, numbers.count)].sorted(by: isLess)
        medians.append(group[group.count / 2])
    }
    // 2. The median of those medians, found by calling select recursively, is the pivot
    let pivot = select(medians, medians.count / 2)

    // 3. Partition three ways around it, and continue in the part that holds index k
    var smaller: [Int] = []
    var larger: [Int] = []
    for value in numbers {
        if isLess(value, pivot) {
            smaller.append(value)
        } else if isLess(pivot, value) {
            larger.append(value)
        }
    }
    let equal = numbers.count - smaller.count - larger.count
    if k < smaller.count {
        return select(smaller, k)
    } else if k < smaller.count + equal {
        return pivot
    } else {
        return select(larger, k - smaller.count - equal)
    }
}

let numbers = [42, 7, 19, 88, 3, 56, 23, 71, 12, 64, 35, 90, 5]
let sortedNumbers = numbers.sorted()
print((0..<numbers.count).allSatisfy { select(numbers, $0) == sortedNumbers[$0] })

for n in [1_000, 10_000, 100_000] {
    var line = "n = \(n):"
    for (name, input) in [("sorted", Array(0..<n)), ("mixed", (0..<n).map { ($0 * 7_919) % n }), ("all equal", Array(repeating: 1, count: n))] {
        comparisons = 0
        let median = select(input, n / 2)
        line += " \(name) \(comparisons / n) per element (median \(median));"
    }
    print(line)
}
