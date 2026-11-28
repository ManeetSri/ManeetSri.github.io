// Generated from src/dsa/content/lessons/recursion/rec-multiple-recursion.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var calls = 0

func paths(_ rows: Int, _ columns: Int) -> Int {
    calls += 1
    if rows == 1 || columns == 1 {
        return 1                     // a single row or column: one straight route
    }
    return paths(rows - 1, columns) + paths(rows, columns - 1)
}

for size in [3, 5, 10, 12] {
    calls = 0
    let count = paths(size, size)
    print("\(size)×\(size): \(count) routes, \(calls) calls")
}
