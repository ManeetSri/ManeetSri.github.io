// Generated from src/dsa/content/lessons/math-basics/math-matrices.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let a = [[1, 2], [3, 4]]
let b = [[5, 6], [7, 8]]
let sum = zip(a, b).map { rowA, rowB in
    zip(rowA, rowB).map { $0 + $1 }
}
print(sum)
