// Generated from src/dsa/content/lessons/arrays/arrays-reverse-rotate.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func reverse(_ numbers: inout [Int], from low: Int, to high: Int) {
    var left = low
    var right = high
    while left < right {
        numbers.swapAt(left, right)
        left += 1
        right -= 1
    }
}

var values = [1, 2, 3, 4, 5, 6, 7, 8]
reverse(&values, from: 2, to: 5)
print(values)

values[0...3].reverse()
print(values)
