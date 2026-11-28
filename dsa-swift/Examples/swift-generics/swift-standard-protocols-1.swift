// Generated from src/dsa/content/lessons/swift-generics/swift-standard-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Card: Equatable {
    var rank: Int
    var suit: String
}

let hand = [Card(rank: 10, suit: "hearts"), Card(rank: 3, suit: "spades")]
let wanted = Card(rank: 3, suit: "spades")

print(hand[1] == wanted)
print(hand.contains(wanted))
print(hand.firstIndex(of: wanted) ?? -1)
print(hand[0] != wanted)
