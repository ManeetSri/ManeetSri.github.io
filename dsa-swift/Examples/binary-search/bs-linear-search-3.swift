// Generated from src/dsa/content/lessons/binary-search/bs-linear-search.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let n = 100_000
let steps = Int.bitWidth - n.leadingZeroBitCount     // about log₂ n: 17 for 100,000

for queries in [1, 10, 100, 10_000] {
    let linear = queries * n
    let sortFirst = n * steps + queries * steps
    print("\(queries) searches: linear \(linear), sort first \(sortFirst)")
}
