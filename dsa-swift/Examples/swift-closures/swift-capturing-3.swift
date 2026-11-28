// Generated from src/dsa/content/lessons/swift-closures/swift-capturing.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func makeCounter() -> () -> Int {
    var count = 0
    return {
        count += 1
        return count
    }
}

let first = makeCounter()
let second = makeCounter()

print(first())
print(first())
print(second())
print(first())
print(second())
