// Generated from src/dsa/content/lessons/number-theory/nt-special-numbers.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Bell numbers with the Bell triangle: each row starts with the last entry of the row above,
// and each entry is the one to its left plus the one above that
var row = [1]
var bell = [1]
for _ in 1...10 {
    var next = [row.last!]
    for value in row {
        next.append(next.last! + value)
    }
    row = next
    bell.append(row[0])
}
print(bell)
