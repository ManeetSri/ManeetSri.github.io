// Generated from src/dsa/content/lessons/bits/bits-xor-tricks.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func missingNumber(_ numbers: [Int]) -> Int {
    var result = numbers.count
    for (index, value) in numbers.enumerated() {
        result ^= index ^ value
    }
    return result
}

print(missingNumber([3, 0, 1]))
print(missingNumber([0, 1, 2, 4, 5]))
print(missingNumber([1]))
