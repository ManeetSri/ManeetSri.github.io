// Generated from src/dsa/content/lessons/hashing/hash-load-factor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var squares: [Int: Int] = [:]
var lastCapacity = squares.capacity
print("count 0, capacity \(lastCapacity)")
for number in 1...200 {
    squares[number] = number * number
    if squares.capacity != lastCapacity {
        lastCapacity = squares.capacity
        print("count \(squares.count), capacity \(lastCapacity)")
    }
}
