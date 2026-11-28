// Generated from src/dsa/content/lessons/swift-control-flow/swift-while.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var n = 6
var path = "\(n)"

repeat {
    if n % 2 == 0 {
        n /= 2
    } else {
        n = 3 * n + 1
    }
    path += " → \(n)"
} while n != 1

print(path)
