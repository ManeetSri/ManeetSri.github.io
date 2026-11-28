// Generated from src/dsa/content/lessons/graph-traversals/gt-components.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

let fourWay = [(-1, 0), (1, 0), (0, -1), (0, 1)]
let eightWay = fourWay + [(-1, -1), (-1, 1), (1, -1), (1, 1)]

func fill(_ picture: [[Character]], from start: (Int, Int), with paint: Character, moves: [(Int, Int)]) -> [[Character]] {
    var picture = picture
    let original = picture[start.0][start.1]
    if original == paint { return picture }            // nothing to do, and no endless loop
    picture[start.0][start.1] = paint
    var stack = [start]
    while let cell = stack.popLast() {
        for (dr, dc) in moves {
            let r = cell.0 + dr
            let c = cell.1 + dc
            guard r >= 0, r < picture.count, c >= 0, c < picture[r].count else { continue }
            guard picture[r][c] == original else { continue }
            picture[r][c] = paint                       // the new colour is the visited mark
            stack.append((r, c))
        }
    }
    return picture
}

let diamond = [
    "....##....",
    "...#..#...",
    "..#....#..",
    "...#..#...",
    "....##....",
].map { Array($0) }

for (name, moves) in [("4-way", fourWay), ("8-way", eightWay)] {
    print(name)
    for row in fill(diamond, from: (2, 4), with: "o", moves: moves) {
        print(String(row))
    }
}
