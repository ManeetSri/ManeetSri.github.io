// Generated from src/dsa/content/lessons/matrices/matrix-traversals.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let square = [
    [1, 2, 3],
    [4, 5, 6],
    [7, 8, 9],
]
let n = square.count
var main = 0
var anti = 0
for i in 0..<n {
    main += square[i][i]
    anti += square[i][n - 1 - i]
}
print(main, anti)
print(main + anti - (n % 2 == 1 ? square[n / 2][n / 2] : 0))
