// Generated from src/dsa/content/lessons/swift-functions/swift-default-variadic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func indexOf(_ target: Int, in numbers: [Int], startingAt start: Int = 0) -> Int? {
    var index = start
    while index < numbers.count {
        if numbers[index] == target {
            return index
        }
        index += 1
    }
    return nil
}

let numbers = [4, 7, 4, 9]
print(indexOf(4, in: numbers) ?? -1)
print(indexOf(4, in: numbers, startingAt: 1) ?? -1)
print(indexOf(8, in: numbers) ?? -1)
