// Generated from src/dsa/content/lessons/hashing/hash-load-factor.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var seen = Set<Int>(minimumCapacity: 1_000)
let reserved = seen.capacity
for value in 0..<1_000 {
    seen.insert(value)
}
print(reserved >= 1_000, seen.capacity == reserved)
