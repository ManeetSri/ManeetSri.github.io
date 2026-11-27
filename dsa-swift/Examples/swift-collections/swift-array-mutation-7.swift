// Generated from src/dsa/content/lessons/swift-collections/swift-array-mutation.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var ranks = [3, 1, 2]
let ordered = ranks.sorted()
print(ranks, ordered)

ranks.sort()
print(ranks)

ranks.reverse()
print(ranks)

ranks.swapAt(0, 2)
print(ranks)
