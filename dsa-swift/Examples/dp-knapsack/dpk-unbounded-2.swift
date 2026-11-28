// Generated from src/dsa/content/lessons/dp-knapsack/dpk-unbounded.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// prices[k - 1] is what a piece of length k sells for
let prices = [2, 5, 9, 11, 14, 17, 20, 22]
let rodLength = 8

var best = Array(repeating: 0, count: rodLength + 1)      // best[len]: the most a rod of length len earns
var firstPiece = Array(repeating: 0, count: rodLength + 1) // the piece cut first in that best plan
for len in 1...rodLength {
    for piece in 1...min(len, prices.count) where prices[piece - 1] + best[len - piece] > best[len] {
        best[len] = prices[piece - 1] + best[len - piece]   // sell one piece, cut the rest as well as possible
        firstPiece[len] = piece
    }
}
print("best:      ", best)
print("first cut: ", firstPiece)

var pieces: [Int] = []
var left = rodLength
while left > 0 {
    pieces.append(firstPiece[left])
    left -= firstPiece[left]
}
print("cut \(rodLength) into \(pieces) for \(best[rodLength])")
