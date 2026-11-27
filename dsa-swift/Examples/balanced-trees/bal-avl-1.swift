// Generated from src/dsa/content/lessons/balanced-trees/bal-avl.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// fewest[h]: the fewest nodes an AVL tree of height h can have
var fewest = [0, 1]
while fewest.count <= 10 {
    let h = fewest.count
    fewest.append(fewest[h - 1] + fewest[h - 2] + 1)    // root + sparsest h - 1 + sparsest h - 2
}
for h in 1...10 {
    let most = (1 << h) - 1                              // a perfect tree: 2^h - 1 nodes
    print("height \(h): fewest \(fewest[h]), most \(most)")
}

// How tall can an AVL tree with a million nodes be?
var height = 1
var smaller = 0      // fewest nodes for height - 1
var current = 1      // fewest nodes for height
while true {
    let next = current + smaller + 1
    if next > 1_000_000 { break }
    smaller = current
    current = next
    height += 1
}
print("a million nodes: at most \(height) levels, at least 20")
