// Generated from src/dsa/content/lessons/swift-optionals/swift-optionals-in-practice.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func spread(of times: [Int]) -> Int? {
    guard let fastest = times.min(), let slowest = times.max() else {
        return nil
    }
    return slowest - fastest
}

print(spread(of: [62, 58, 65, 57, 60]) ?? 0)
print(spread(of: []) == nil)
