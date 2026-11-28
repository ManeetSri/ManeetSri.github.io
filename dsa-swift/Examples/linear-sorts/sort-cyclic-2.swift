// Generated from src/dsa/content/lessons/linear-sorts/sort-cyclic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var numbers = (0..<10_000).map { ($0 * 7_919) % 10_000 + 1 }     // 1 to 10,000, mixed up
var swaps = 0
var steps = 0
var i = 0
while i < numbers.count {
    steps += 1
    let home = numbers[i] - 1
    if numbers[i] != numbers[home] {
        numbers.swapAt(i, home)
        swaps += 1
    } else {
        i += 1
    }
}
print("swaps:", swaps, "steps:", steps, "sorted:", numbers == Array(1...10_000))
