// Generated from src/dsa/content/lessons/swift-tooling/swift-assertions-defer.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func find(_ target: Int, in numbers: [Int]) -> Int? {
    print("searching for \(target)")
    defer { print("finished searching for \(target)") }
    for (index, number) in numbers.enumerated() where number == target {
        return index
    }
    return nil
}

print(find(7, in: [3, 7, 9]) ?? -1)
print(find(5, in: [3, 7, 9]) ?? -1)
