// Generated from src/dsa/content/lessons/dp-lis/lis-n-log-n.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Patience sorting: each card goes on the leftmost pile whose top is at least as big,
// or starts a new pile on the right
let cards = [10, 9, 2, 5, 3, 7, 101, 18]
var piles: [[Int]] = []
for card in cards {
    if let index = piles.firstIndex(where: { $0.last! >= card }) {
        piles[index].append(card)
    } else {
        piles.append([card])
    }
    print("after \(card), tops:", piles.map { $0.last! })
}
print("piles:", piles)
