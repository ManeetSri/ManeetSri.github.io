// Generated from src/dsa/content/lessons/swift-collections/swift-2d-arrays.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let triangle = [
    [1],
    [1, 1],
    [1, 2, 1],
    [1, 3, 3, 1],
]
for row in triangle {
    print(row.count, row)
}
