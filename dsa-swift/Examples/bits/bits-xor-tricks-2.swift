// Generated from src/dsa/content/lessons/bits/bits-xor-tricks.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let numbers = [4, 1, 2, 1, 2]
var running = 0
for number in numbers {
    running ^= number
    print(number, running)
}
print([7, -3, 7, 9, 9].reduce(0, ^))
