// Generated from src/dsa/content/lessons/greedy/greedy-huffman.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Huffman's cost: repeatedly merge the two lightest weights and add up every merged weight
func huffmanCost(_ weights: [Int]) -> Int {
    var forest = weights
    var cost = 0
    while forest.count > 1 {
        forest.sort()                                  // fine for a handful; a heap in real code
        let merged = forest[0] + forest[1]
        forest.removeFirst(2)
        forest.append(merged)
        cost += merged
    }
    return cost
}

// Every tree can be built by some sequence of merges, so try them all
func cheapestOfAllMerges(_ weights: [Int]) -> Int {
    if weights.count <= 1 { return 0 }
    var best = Int.max
    for i in weights.indices {
        for j in weights.indices where j > i {
            var rest = weights
            let merged = rest[i] + rest[j]
            rest.remove(at: j)
            rest.remove(at: i)
            rest.append(merged)
            best = min(best, merged + cheapestOfAllMerges(rest))
        }
    }
    return best
}

for weights in [[5, 2, 2, 1, 1], [1, 1, 1, 1], [10, 1, 1, 1], [3, 4, 5, 6, 7, 8]] {
    print(weights, "Huffman", huffmanCost(weights), "best of all", cheapestOfAllMerges(weights))
}
