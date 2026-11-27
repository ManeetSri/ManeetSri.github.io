// Generated from src/dsa/content/lessons/efficient-sorts/sort-quick.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

// Quick sort isn't stable: watch two cards with the same rank
struct Card {
    let rank: Int
    let suit: String
}

func partition(_ items: inout [Card], _ low: Int, _ high: Int) -> Int {
    let pivot = items[high].rank
    var boundary = low
    for j in low..<high where items[j].rank < pivot {
        items.swapAt(boundary, j)
        boundary += 1
    }
    items.swapAt(boundary, high)
    return boundary
}

func quickSort(_ items: inout [Card], _ low: Int, _ high: Int) {
    guard low < high else { return }
    let p = partition(&items, low, high)
    quickSort(&items, low, p - 1)
    quickSort(&items, p + 1, high)
}

var hand = [Card(rank: 7, suit: "♠"), Card(rank: 7, suit: "♥"), Card(rank: 9, suit: "♣")]
quickSort(&hand, 0, hand.count - 1)
print(hand.map { "\($0.rank)\($0.suit)" })
