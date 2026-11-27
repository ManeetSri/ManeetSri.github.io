// Generated from src/dsa/content/lessons/complexity/bigo-recurrences.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

var moves = 0

// T(n) = 2T(n − 1) + 1: move n − 1 discs aside, move the biggest, move n − 1 back on top
func hanoi(_ discs: Int) {
    if discs == 0 {
        return
    }
    hanoi(discs - 1)
    moves += 1
    hanoi(discs - 1)
}

for discs in [1, 2, 3, 10, 20] {
    moves = 0
    hanoi(discs)
    print("n = \(discs): moves \(moves)")
}
