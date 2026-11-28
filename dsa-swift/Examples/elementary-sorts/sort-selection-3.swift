// Generated from src/dsa/content/lessons/elementary-sorts/sort-selection.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

func selectionSort(_ cards: inout [(rank: Int, name: String)]) {
    guard cards.count > 1 else { return }
    for i in 0..<(cards.count - 1) {
        var smallest = i
        for j in (i + 1)..<cards.count where cards[j].rank < cards[smallest].rank {
            smallest = j
        }
        if smallest != i {
            cards.swapAt(i, smallest)
        }
    }
}

var hand = [(rank: 5, name: "5♥"), (rank: 5, name: "5♠"), (rank: 2, name: "2♦")]
selectionSort(&hand)
print(hand.map(\.name))
