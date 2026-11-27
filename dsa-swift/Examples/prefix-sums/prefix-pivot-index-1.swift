// Generated from src/dsa/content/lessons/prefix-sums/prefix-pivot-index.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func pivotSlowly(_ numbers: [Int]) -> Int? {
    for i in numbers.indices {
        let left = numbers[..<i].reduce(0, +)
        let right = numbers[(i + 1)...].reduce(0, +)
        if left == right {
            return i
        }
    }
    return nil
}

print(pivotSlowly([2, 3, -1, 8, 4]) as Any)
print(pivotSlowly([1, 2, 3]) as Any)
