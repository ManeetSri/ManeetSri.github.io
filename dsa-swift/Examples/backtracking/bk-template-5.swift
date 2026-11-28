// Generated from src/dsa/content/lessons/backtracking/bk-template.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func countNodes(wheels: Int, digits: Int) -> (nodes: Int, leaves: Int) {
    var nodes = 0
    var leaves = 0
    func explore(_ depth: Int, _ previous: Int) {     // previous is 0 before the first wheel
        nodes += 1
        if depth == wheels {
            leaves += 1
            return
        }
        for digit in 1...digits where digit != previous {
            explore(depth + 1, digit)
        }
    }
    explore(0, 0)
    return (nodes, leaves)
}

for wheels in [3, 6, 10] {
    let (nodes, leaves) = countNodes(wheels: wheels, digits: 3)
    print("\(wheels) wheels: \(leaves) codes, \(nodes) nodes in the tree")
}
