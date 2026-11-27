// Generated from src/dsa/content/lessons/problem-solving/algo-invariants.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reverseInPlace(_ items: inout [Int]) {
    var left = 0
    var right = items.count - 1
    while left < right {
        items.swapAt(left, right)
        left += 1
        right -= 1
    }
}

var odd = [1, 2, 3, 4, 5]
reverseInPlace(&odd)
print(odd)

var even = [1, 2, 3, 4]
reverseInPlace(&even)
print(even)

var empty: [Int] = []
reverseInPlace(&empty)
print(empty)
