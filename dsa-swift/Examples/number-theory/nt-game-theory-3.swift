// Generated from src/dsa/content/lessons/number-theory/nt-game-theory.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Brute force: search every move of three-pile Nim, remembering each position's result
var memo: [[Int]: Bool] = [:]
func playerToMoveWins(_ piles: [Int]) -> Bool {
    if let known = memo[piles] { return known }
    var result = false
    for i in piles.indices where !result {
        for take in stride(from: 1, through: piles[i], by: 1) {
            var next = piles
            next[i] -= take
            if !playerToMoveWins(next) {
                result = true
                break
            }
        }
    }
    memo[piles] = result
    return result
}

var positions = 0
var agree = 0
for a in 0...5 {
    for b in 0...5 {
        for c in 0...5 {
            positions += 1
            if playerToMoveWins([a, b, c]) == ((a ^ b ^ c) != 0) { agree += 1 }
        }
    }
}
print(positions, agree)
