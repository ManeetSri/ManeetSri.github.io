// Generated from src/dsa/content/lessons/matrices/matrix-traversals.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let rows = 3
let columns = 4
var flat = Array(repeating: 0, count: rows * columns)
for r in 0..<rows {
    for c in 0..<columns {
        flat[r * columns + c] = r * 10 + c
    }
}
print(flat)

let index = 7
print("index \(index) is row \(index / columns), column \(index % columns)")
