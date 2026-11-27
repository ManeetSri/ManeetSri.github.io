// Generated from src/dsa/content/lessons/math-basics/math-matrices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let a = [[1, 0, 2], [0, 3, 1]]
print(a.count, a[0].count)
print(a[0][2], a[1][1])

var zeros = Array(repeating: Array(repeating: 0, count: 3), count: 2)
zeros[1][2] = 7
print(zeros)
