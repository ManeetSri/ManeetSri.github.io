// Generated from src/dsa/content/lessons/tries/trie-word-search-2.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var word: String?                                   // the word that ends here, if any
}

func findWords(_ board: [[Character]], _ words: [String]) -> [String] {
    let root = Node()
    for word in words {
        var node = root
        for character in word {
            if node.children[character] == nil {
                node.children[character] = Node()
            }
            node = node.children[character]!
        }
        node.word = word
    }

    var grid = board
    let rows = grid.count
    let columns = grid[0].count
    var found: [String] = []

    func search(_ row: Int, _ column: Int, _ parent: Node) {
        guard row >= 0, row < rows, column >= 0, column < columns else { return }
        let letter = grid[row][column]
        guard let node = parent.children[letter] else { return }    // no word continues this way
        if let word = node.word {
            found.append(word)
            node.word = nil                             // report each word once
        }
        grid[row][column] = "#"                         // used on this path
        for (dr, dc) in [(-1, 0), (0, 1), (1, 0), (0, -1)] {
            search(row + dr, column + dc, node)
        }
        grid[row][column] = letter                      // free again for other paths
        if node.word == nil && node.children.isEmpty {
            parent.children[letter] = nil               // prune: nothing left to find below here
        }
    }

    for row in 0..<rows {
        for column in 0..<columns {
            search(row, column, root)
        }
    }
    return found.sorted()
}

let board: [[Character]] = [
    ["c", "a", "t", "s"],
    ["o", "r", "e", "h"],
    ["d", "e", "a", "t"],
    ["s", "n", "o", "w"],
]
let words = ["cat", "cats", "care", "core", "code", "heat", "hat", "snow", "seat", "tea", "rate", "dent", "tears"]
print(findWords(board, words))
