// Generated from src/dsa/content/lessons/elementary-sorts/sort-insertion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var received: [Int] = []
var shifts = 0
for timestamp in [100, 102, 101, 105, 103, 104, 108, 107] {
    received.append(timestamp)
    var gap = received.count - 1
    while gap > 0 && received[gap - 1] > timestamp {
        received[gap] = received[gap - 1]
        gap -= 1
        shifts += 1
    }
    received[gap] = timestamp
}
print(received, "shifts:", shifts)
