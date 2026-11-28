// Reference solution: Word hunt on a grid. Put the words in a trie, with each word stored at the node
// where it ends. Start a depth-first search from every cell, walking the trie alongside the grid: a
// cell is only entered if the current node has a child for its letter, so dead prefixes are never
// explored. A found word is recorded and cleared from its node, visited cells are marked in place and
// restored on the way back, and a node left with no word and no children is cut from its parent, so
// later searches skip branches that can't produce anything new. Worst case O(cells × 4 × 3^(L − 1))
// for words of up to L letters, plus O(total characters) to build the trie.

public enum GridWordHunt {
    final class Node {
        var children = [Node?](repeating: nil, count: 26)
        var childCount = 0
        var word: String?
    }

    public static func findWords(in board: [[Character]], words: [String]) -> [String] {
        let root = Node()
        for word in words {
            var node = root
            for byte in word.utf8 {
                let slot = Int(byte - 97)
                if node.children[slot] == nil {
                    node.children[slot] = Node()
                    node.childCount += 1
                }
                node = node.children[slot]!
            }
            node.word = word
        }

        let visited: UInt8 = 35                  // "#", never a letter
        var grid = board.map { row in row.map { $0.asciiValue! } }
        let rows = grid.count
        let columns = grid.first?.count ?? 0
        let moves = [(-1, 0), (0, 1), (1, 0), (0, -1)]
        var found: [String] = []

        func search(_ row: Int, _ column: Int, from parent: Node) {
            let letter = grid[row][column]
            guard letter != visited, let node = parent.children[Int(letter - 97)] else { return }
            if let word = node.word {
                found.append(word)
                node.word = nil                  // each word is reported once
            }
            if node.childCount > 0 {
                grid[row][column] = visited
                for (dr, dc) in moves {
                    let r = row + dr
                    let c = column + dc
                    if r >= 0 && r < rows && c >= 0 && c < columns {
                        search(r, c, from: node)
                    }
                }
                grid[row][column] = letter
            }
            if node.word == nil && node.childCount == 0 {
                parent.children[Int(letter - 97)] = nil      // nothing left to find down here
                parent.childCount -= 1
            }
        }

        for row in 0..<rows {
            for column in 0..<columns {
                search(row, column, from: root)
            }
        }
        return found.sorted()
    }
}
