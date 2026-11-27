// Generated from src/dsa/content/lessons/arrays/arrays-kadane.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [-2, 1, -3, 4, -1, 2, 1, -5, 4]
var current = numbers[0]
var best = numbers[0]
print("value", numbers[0], "current", current, "best", best)
for value in numbers.dropFirst() {
    current = max(value, current + value)
    best = max(best, current)
    print("value", value, "current", current, "best", best)
}
