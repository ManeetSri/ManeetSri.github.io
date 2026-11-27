// Generated from src/dsa/content/lessons/efficient-sorts/sort-lower-bound.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Sorting three values with as few comparisons as possible: a decision tree written as code
var comparisons = 0

func isLess(_ x: Int, _ y: Int) -> Bool {
    comparisons += 1
    return x < y
}

func sortThree(_ a: Int, _ b: Int, _ c: Int) -> [Int] {
    if isLess(a, b) {                        // a < b
        if isLess(b, c) { return [a, b, c] }
        if isLess(a, c) { return [a, c, b] }
        return [c, a, b]
    } else {                                 // b < a
        if isLess(a, c) { return [b, a, c] }
        if isLess(b, c) { return [b, c, a] }
        return [c, b, a]
    }
}

for input in [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]] {
    comparisons = 0
    let result = sortThree(input[0], input[1], input[2])
    print(input, "→", result, "after \(comparisons) comparisons")
}
