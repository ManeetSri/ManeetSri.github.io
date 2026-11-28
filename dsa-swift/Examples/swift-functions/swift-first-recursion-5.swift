// Generated from src/dsa/content/lessons/swift-functions/swift-first-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sum(upTo n: Int) -> Int {
    if n <= 0 {
        return 0
    }
    return n + sum(upTo: n - 1)
}

print(sum(upTo: 4))
print(sum(upTo: 100))
