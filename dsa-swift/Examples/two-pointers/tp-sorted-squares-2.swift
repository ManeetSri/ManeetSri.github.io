// Generated from src/dsa/content/lessons/two-pointers/tp-sorted-squares.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sortedSquares(_ sorted: [Int]) -> [Int] {
    var result = Array(repeating: 0, count: sorted.count)
    var left = 0
    var right = sorted.count - 1
    var write = sorted.count - 1             // the next slot to fill, from the back
    while left <= right {
        let leftSquare = sorted[left] * sorted[left]
        let rightSquare = sorted[right] * sorted[right]
        if leftSquare > rightSquare {
            result[write] = leftSquare
            left += 1
        } else {
            result[write] = rightSquare
            right -= 1
        }
        write -= 1
    }
    return result
}

print(sortedSquares([-7, -3, -1, 2, 4, 6]))
print(sortedSquares([-5, -4, -2]))
print(sortedSquares([0, 3, 8]))
print(sortedSquares([-2, -2, 2]))
print(sortedSquares([]))
