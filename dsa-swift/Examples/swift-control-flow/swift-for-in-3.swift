// Generated from src/dsa/content/lessons/swift-control-flow/swift-for-in.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var evenCount = 0
var squares = ""

for n in 1...6 {
    if n % 2 == 0 {
        evenCount += 1
    }
    squares += "\(n * n) "
}
print("Evens: \(evenCount)")
print("Squares: \(squares)")
