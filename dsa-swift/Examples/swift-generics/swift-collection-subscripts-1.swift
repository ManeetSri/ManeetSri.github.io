// Generated from src/dsa/content/lessons/swift-generics/swift-collection-subscripts.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Board {
    private var cells = Array(repeating: Character("."), count: 9)

    subscript(row: Int, column: Int) -> Character {
        get {
            cells[row * 3 + column]
        }
        set {
            cells[row * 3 + column] = newValue
        }
    }

    var picture: String {
        stride(from: 0, to: 9, by: 3)
            .map { String(cells[$0..<$0 + 3]) }
            .joined(separator: "\n")
    }
}

var board = Board()
board[1, 1] = "X"
board[0, 2] = "O"
board[2, 0] = "X"
print(board[1, 1])
print(board.picture)
