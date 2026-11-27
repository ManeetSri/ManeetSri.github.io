// Generated from src/dsa/content/lessons/complexity/bigo-amortised.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var numbers: [Int] = []
numbers.reserveCapacity(1_000)
let reserved = numbers.capacity
for value in 0..<1_000 {
    numbers.append(value)
}
print(reserved, numbers.capacity)
