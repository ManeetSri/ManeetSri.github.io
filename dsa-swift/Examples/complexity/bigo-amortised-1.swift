// Generated from src/dsa/content/lessons/complexity/bigo-amortised.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var numbers: [Int] = []
var lastCapacity = numbers.capacity
print("count 0, capacity \(lastCapacity)")
for value in 1...100 {
    numbers.append(value)
    if numbers.capacity != lastCapacity {
        print("count \(numbers.count), capacity \(numbers.capacity)")
        lastCapacity = numbers.capacity
    }
}
