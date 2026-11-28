// Generated from src/dsa/content/lessons/problem-solving/algo-what-is-an-algorithm.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func isInOrder(_ numbers: [Int]) -> Bool {
    if numbers.count < 2 {
        return true
    }
    for index in 1..<numbers.count {
        if numbers[index - 1] > numbers[index] {
            return false
        }
    }
    return true
}

print(isInOrder([2, 2, 5, 8]))
print(isInOrder([1, 5, 3, 9]))
print(isInOrder([7]))
print(isInOrder([]))
