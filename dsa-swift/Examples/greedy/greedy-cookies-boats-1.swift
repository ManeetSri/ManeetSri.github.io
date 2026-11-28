// Generated from src/dsa/content/lessons/greedy/greedy-cookies-boats.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Smallest first: each biscuit goes to the least greedy child still waiting, if it's big enough
func happyFromSmallest(greed: [Int], biscuits: [Int]) -> Int {
    let children = greed.sorted(), sizes = biscuits.sorted()
    var child = 0
    for size in sizes where child < children.count && size >= children[child] {
        child += 1
    }
    return child
}

// Biggest first: the biggest biscuit left goes to the greediest child it satisfies
func happyFromBiggest(greed: [Int], biscuits: [Int]) -> Int {
    let children = greed.sorted(by: >), sizes = biscuits.sorted(by: >)
    var biscuit = 0
    for need in children where biscuit < sizes.count && sizes[biscuit] >= need {
        biscuit += 1                    // children no biscuit can satisfy are skipped
    }
    return biscuit
}

let greed = [5, 2, 8, 3], biscuits = [4, 1, 3, 9, 2]
print(happyFromSmallest(greed: greed, biscuits: biscuits), happyFromBiggest(greed: greed, biscuits: biscuits))
