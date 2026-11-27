// Generated from src/dsa/content/lessons/hashing/hash-grouping-consecutive.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestRun(_ numbers: [Int]) -> Int {
    let present = Set(numbers)
    var longest = 0
    for start in present where !present.contains(start - 1) {
        var length = 1
        while present.contains(start + length) {
            length += 1
        }
        longest = max(longest, length)
    }
    return longest
}

print(longestRun([12, 4, 200, 1, 3, 2]))
print(longestRun([7, 7, 8, 9, 9, 20]))
print(longestRun([]))
