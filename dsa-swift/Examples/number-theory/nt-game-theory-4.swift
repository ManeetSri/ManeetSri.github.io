// Generated from src/dsa/content/lessons/number-theory/nt-game-theory.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// The minimum excludant: the smallest non-negative integer not in the list
func mex(_ values: [Int]) -> Int {
    var seen = Array(repeating: false, count: values.count + 1)
    for v in values where v < seen.count { seen[v] = true }
    return seen.firstIndex(of: false)!
}

// Grundy numbers for one pile when a move removes 1, 3 or 4 stones
let moves = [1, 3, 4]
var grundy: [Int] = []
for n in 0...20 {
    grundy.append(mex(moves.filter { $0 <= n }.map { grundy[n - $0] }))
}
print(grundy)
print(mex([0, 1, 3]), mex([1, 2]), mex([]))
// A sum of three such piles: XOR their Grundy numbers
let piles = [5, 6, 9]
print(piles.map { grundy[$0] }, piles.map { grundy[$0] }.reduce(0, ^))
