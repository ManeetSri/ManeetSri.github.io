// Generated from src/dsa/content/lessons/tree-basics/tree-node-swift.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

indirect enum Tree {
    case empty
    case node(Tree, Int, Tree)
}

func values(_ tree: Tree) -> [Int] {             // left subtree, root, right subtree
    switch tree {
    case .empty:
        return []
    case let .node(left, value, right):
        return values(left) + [value] + values(right)
    }
}

// A new tree with an extra leaf at the far left. Only the nodes on the way down are rebuilt.
func addingLeftmost(_ newValue: Int, to tree: Tree) -> Tree {
    switch tree {
    case .empty:
        return .node(.empty, newValue, .empty)
    case let .node(left, value, right):
        return .node(addingLeftmost(newValue, to: left), value, right)
    }
}

let original = Tree.node(.node(.empty, 2, .empty), 5, .node(.empty, 8, .empty))
let bigger = addingLeftmost(1, to: original)
print("original:", values(original))
print("bigger:  ", values(bigger))
