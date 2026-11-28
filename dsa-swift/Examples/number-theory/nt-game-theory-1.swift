// Generated from src/dsa/content/lessons/number-theory/nt-game-theory.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// One pile, take 1, 2 or 3 stones; whoever takes the last stone wins.
// A position wins if some move leads to a losing position for the opponent.
var wins = [false]                       // 0 stones: no move, so the player to move has lost
for n in 1...12 {
    wins.append([1, 2, 3].contains { $0 <= n && !wins[n - $0] })
}
print((0...12).filter { !wins[$0] })     // the losing positions
