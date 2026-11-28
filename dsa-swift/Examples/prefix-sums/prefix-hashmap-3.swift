// Generated from src/dsa/content/lessons/prefix-sums/prefix-hashmap.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [1, 2, -1, 3, -2, 2]
let k = 3
var seen: [Int: Int] = [0: 1]
var running = 0
var count = 0
for value in numbers {
    running += value
    let found = seen[running - k, default: 0]
    count += found
    seen[running, default: 0] += 1
    print("value \(value): running \(running), look for \(running - k), found \(found), count \(count)")
}
