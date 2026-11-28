// Generated from src/dsa/content/lessons/swift-types/swift-copy-on-write-intro.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func sharesStorage(_ first: [Int], _ second: [Int]) -> Bool {
    first.withUnsafeBufferPointer { one in
        second.withUnsafeBufferPointer { two in
            one.baseAddress == two.baseAddress
        }
    }
}

var board = [0, 0, 0, 0]
var history: [[Int]] = []

for step in 0..<3 {
    history.append(board)
    let sharedBeforeWrite = sharesStorage(board, history[step])
    board[step] = step + 1
    print("Step \(step): shared before write? \(sharedBeforeWrite). Board is now \(board)")
}
print(history)
