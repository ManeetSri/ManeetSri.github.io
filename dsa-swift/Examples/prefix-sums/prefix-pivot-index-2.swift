// Generated from src/dsa/content/lessons/prefix-sums/prefix-pivot-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func pivotIndex(_ numbers: [Int]) -> Int? {
    let total = numbers.reduce(0, +)
    var leftSum = 0
    for (i, value) in numbers.enumerated() {
        let rightSum = total - leftSum - value
        if leftSum == rightSum {
            return i
        }
        leftSum += value               // only now does value join the left side
    }
    return nil
}

print(pivotIndex([2, 3, -1, 8, 4]) as Any)
print(pivotIndex([3, -3, 7]) as Any)
print(pivotIndex([1, 2, 3]) as Any)
print(pivotIndex([5]) as Any)
print(pivotIndex([0, 0, 0]) as Any)
print(pivotIndex([]) as Any)
