// Generated from src/dsa/content/lessons/swift-functions/swift-nested-functions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reverseEachHalf(_ numbers: inout [Int]) {
    // Reverses numbers[start...end] in place
    func reverse(from start: Int, to end: Int) {
        var left = start
        var right = end
        while left < right {
            numbers.swapAt(left, right)
            left += 1
            right -= 1
        }
    }

    let middle = numbers.count / 2
    reverse(from: 0, to: middle - 1)
    reverse(from: middle, to: numbers.count - 1)
}

var values = [1, 2, 3, 4, 5, 6]
reverseEachHalf(&values)
print(values)
