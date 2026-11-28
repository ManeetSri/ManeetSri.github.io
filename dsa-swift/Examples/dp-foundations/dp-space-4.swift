// Generated from src/dsa/content/lessons/dp-foundations/dp-space.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let size = 7

// One row, updated from right to left: row[k - 1] still holds the previous row's value when it's read
var row = Array(repeating: 0, count: size)
row[0] = 1
for n in 1..<size {
    for k in stride(from: n, through: 1, by: -1) {
        row[k] += row[k - 1]
    }
}
print("right to left:", row)

// The same update from left to right reads row[k - 1] after it has already changed
var wrong = Array(repeating: 0, count: size)
wrong[0] = 1
for n in 1..<size {
    for k in 1...n {
        wrong[k] += wrong[k - 1]
    }
}
print("left to right:", wrong)
