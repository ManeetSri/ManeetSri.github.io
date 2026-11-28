// Generated from src/dsa/content/lessons/swift-collections/swift-counting-grouping.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func firstUnique(_ numbers: [Int]) -> Int? {
    var counts: [Int: Int] = [:]
    for number in numbers {
        counts[number, default: 0] += 1
    }
    for number in numbers where counts[number] == 1 {
        return number
    }
    return nil
}

print(firstUnique([4, 5, 4, 6, 5, 7]) ?? -1)
print(firstUnique([1, 1]) ?? -1)
