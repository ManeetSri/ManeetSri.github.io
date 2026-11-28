// Generated from src/dsa/content/lessons/graph-basics/graph-dense-sparse.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// "4 stations, numbered 1 to 4" and four tracks, as a problem might give them
let n = 4
let edges = [[1, 2], [2, 3], [3, 1], [3, 4]]

// Option 1: shift every label down by one as you read it, and back up when you report
var shifted = Array(repeating: [Int](), count: n)
for edge in edges {
    let (u, v) = (edge[0] - 1, edge[1] - 1)
    shifted[u].append(v)
    shifted[v].append(u)
}
print("shifted:", shifted)

// Option 2: allocate n + 1 lists and leave slot 0 unused
var padded = Array(repeating: [Int](), count: n + 1)
for edge in edges {
    padded[edge[0]].append(edge[1])
    padded[edge[1]].append(edge[0])
}
print("padded:", padded)
print("station 3's neighbours:", padded[3], "or", shifted[2].map { $0 + 1 })
