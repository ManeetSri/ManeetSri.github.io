// Generated from src/dsa/content/lessons/dp-intervals/dpi-optimal-bst.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func optimalBST(keys: [Int], freq: [Int]) -> (cost: Int, root: [[Int]]) {
    let n = keys.count
    var prefix = [0]                                     // prefix[i]: freq[0] + … + freq[i - 1]
    for f in freq {
        prefix.append(prefix.last! + f)
    }
    var cost = Array(repeating: Array(repeating: 0, count: n + 1), count: n + 1)   // keys i..<j
    var root = Array(repeating: Array(repeating: -1, count: n + 1), count: n + 1)
    for length in stride(from: 1, through: n, by: 1) {
        for i in 0...(n - length) {
            let j = i + length
            cost[i][j] = Int.max
            for r in i..<j where cost[i][r] + cost[r + 1][j] < cost[i][j] {
                cost[i][j] = cost[i][r] + cost[r + 1][j]  // left: i..<r, right: r + 1..<j
                root[i][j] = r
            }
            cost[i][j] += prefix[j] - prefix[i]           // everything in the range goes one level down
        }
    }
    return (cost[0][n], root)
}

let keys = [10, 20, 30, 40]
let result = optimalBST(keys: keys, freq: [4, 2, 6, 3])
print("cost:", result.cost)

// Print the tree sideways: each node, then its left and right subtrees indented
func show(_ i: Int, _ j: Int, depth: Int, side: String) {
    guard i < j else { return }
    let r = result.root[i][j]
    print(String(repeating: "    ", count: depth) + side + String(keys[r]))
    show(i, r, depth: depth + 1, side: "L: ")
    show(r + 1, j, depth: depth + 1, side: "R: ")
}
show(0, keys.count, depth: 0, side: "")
