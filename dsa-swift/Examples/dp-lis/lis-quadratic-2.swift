// Generated from src/dsa/content/lessons/dp-lis/lis-quadratic.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func longestChain(_ items: [Int], canFollow: (Int, Int) -> Bool) -> Int {
    var length = Array(repeating: 1, count: items.count)
    for i in items.indices {
        for j in 0..<i where canFollow(items[j], items[i]) {
            length[i] = max(length[i], length[j] + 1)
        }
    }
    return length.max() ?? 0
}

let readings = [3, 3, 1, 2, 2, 5, 4]
print("strictly increasing:", longestChain(readings) { $0 < $1 })
print("non-decreasing:", longestChain(readings) { $0 <= $1 })
print("strictly decreasing:", longestChain(readings) { $0 > $1 })
