// Generated from src/dsa/content/lessons/matrices/matrix-directions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let moves = [(-1, 0), (0, 1), (1, 0), (0, -1)]       // clockwise: up, right, down, left
let names = ["up", "right", "down", "left"]
let size = 5
var row = 2
var column = 2
var heading = 0

for command in "FFRFFFLLF" {
    switch command {
    case "R":
        heading = (heading + 1) % 4
    case "L":
        heading = (heading + 3) % 4
    default:
        let (dr, dc) = moves[heading]
        let r = row + dr
        let c = column + dc
        if r >= 0 && r < size && c >= 0 && c < size {    // a wall stops the move
            row = r
            column = c
        }
    }
}
print(row, column, names[heading])
