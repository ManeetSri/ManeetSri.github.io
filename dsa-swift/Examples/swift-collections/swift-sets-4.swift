// Generated from src/dsa/content/lessons/swift-collections/swift-sets.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstRepeat(_ numbers: [Int]) -> Int? {
    var seen = Set<Int>()
    for number in numbers {
        if seen.contains(number) {
            return number
        }
        seen.insert(number)
    }
    return nil
}

print(firstRepeat([4, 2, 7, 2, 4]) ?? -1)
print(firstRepeat([1, 2, 3]) ?? -1)
