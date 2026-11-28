// Generated from src/dsa/content/lessons/greedy/greedy-proofs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func happyChildren(greed: [Int], biscuits: [Int]) -> Int {
    let children = greed.sorted()
    var child = 0                                   // the least greedy child still waiting
    for size in biscuits.sorted() where child < children.count {
        if size >= children[child] {
            print("biscuit \(size) -> child with greed \(children[child])")
            child += 1
        } else {
            print("biscuit \(size) is too small for anyone left")
        }
    }
    return child
}

print(happyChildren(greed: [5, 2, 8, 3], biscuits: [4, 1, 3, 9, 2]))
