// Generated from src/dsa/content/lessons/swift-functions/swift-inout-swap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reverseInPlace(_ numbers: inout [Int]) {
    var left = 0
    var right = numbers.count - 1
    while left < right {
        numbers.swapAt(left, right)
        print("Swapped indices \(left) and \(right): \(numbers)")
        left += 1
        right -= 1
    }
}

var values = [1, 2, 3, 4, 5]
reverseInPlace(&values)
print(values)
