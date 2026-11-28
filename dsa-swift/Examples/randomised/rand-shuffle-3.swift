// Generated from src/dsa/content/lessons/randomised/rand-shuffle.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Count exactly: every sequence of choices the "anywhere" shuffle can make for three items
let orders = [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
var counts = [Int](repeating: 0, count: orders.count)
for first in 0..<3 {
    for second in 0..<3 {
        for third in 0..<3 {
            var items = [0, 1, 2]
            items.swapAt(0, first)
            items.swapAt(1, second)
            items.swapAt(2, third)
            counts[orders.firstIndex(of: items)!] += 1
        }
    }
}
print(counts, counts.reduce(0, +))
