// Generated from src/dsa/content/lessons/math-basics/math-counting.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var row = [1]
for _ in 0..<6 {
    print(row)
    var next = [1]
    for i in 1..<row.count {
        next.append(row[i - 1] + row[i])
    }
    next.append(1)
    row = next
}
