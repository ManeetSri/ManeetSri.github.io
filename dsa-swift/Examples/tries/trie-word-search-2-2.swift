// Generated from src/dsa/content/lessons/tries/trie-word-search-2.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Node {
    var children: [Character: Node] = [:]
    var word: String?
}

func countCalls(_ board: [[Character]], _ words: [String], prune: Bool) -> (found: Int, calls: Int) {
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
    var found = 0
    var calls = 0

    func search(_ row: Int, _ column: Int, _ parent: Node) {
        calls += 1
        guard row >= 0, row < rows, column >= 0, column < columns else { return }
        let letter = grid[row][column]
        guard let node = parent.children[letter] else { return }
        if node.word != nil {
            found += 1
            node.word = nil
        }
        grid[row][column] = "#"
        for (dr, dc) in [(-1, 0), (0, 1), (1, 0), (0, -1)] {
            search(row + dr, column + dc, node)
        }
        grid[row][column] = letter
        if prune && node.word == nil && node.children.isEmpty {
            parent.children[letter] = nil
        }
    }
    for row in 0..<rows {
        for column in 0..<columns {
            search(row, column, root)
        }
    }
    return (found, calls)
}

let board = Array(repeating: Array(repeating: Character("a"), count: 5), count: 5)
let words = (1...10).map { String(repeating: "a", count: $0) }
let without = countCalls(board, words, prune: false)
let with = countCalls(board, words, prune: true)
print("without pruning:", without.found, "words,", without.calls, "calls")
print("with pruning:", with.found, "words,", with.calls, "calls")
