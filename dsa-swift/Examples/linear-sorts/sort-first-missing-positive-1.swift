// Generated from src/dsa/content/lessons/linear-sorts/sort-first-missing-positive.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstMissingPositive(_ numbers: inout [Int]) -> Int {
    let n = numbers.count
    var i = 0
    while i < n {
        let value = numbers[i]
        if value >= 1 && value <= n && numbers[value - 1] != value {
            numbers.swapAt(i, value - 1)          // send it home
        } else {
            i += 1                                // out of range, a spare copy, or already home
        }
    }
    print("after:", numbers)
    for index in 0..<n where numbers[index] != index + 1 {
        return index + 1
    }
    return n + 1
}

var a = [7, 3, -2, 1, 9, 2]
print(firstMissingPositive(&a))
var b = [2, 1, 3]
print(firstMissingPositive(&b))
var c = [0, -5, 8]
print(firstMissingPositive(&c))
