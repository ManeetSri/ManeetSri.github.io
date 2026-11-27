// Generated from src/dsa/content/lessons/hashing/hash-grouping-consecutive.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var steps = 0

func walkFromEach(_ starts: [Int], in present: Set<Int>) {
    for start in starts where !present.contains(start - 1) {
        var next = start + 1
        while present.contains(next) {
            steps += 1
            next += 1
        }
    }
}

let numbers = Array(repeating: 0, count: 1_000) + Array(0..<1_000)
let present = Set(numbers)

walkFromEach(numbers, in: present)
print("looping over the array:", steps)
steps = 0
walkFromEach(Array(present), in: present)
print("looping over the set:", steps)
