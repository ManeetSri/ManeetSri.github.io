// Generated from src/dsa/content/lessons/swift-generics/swift-standard-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Player: Comparable, CustomStringConvertible {
    var name: String
    var score: Int

    // Higher scores rank first; equal scores go alphabetically
    static func < (lhs: Player, rhs: Player) -> Bool {
        if lhs.score != rhs.score {
            return lhs.score > rhs.score
        }
        return lhs.name < rhs.name
    }

    var description: String {
        "\(name) (\(score))"
    }
}

let players = [
    Player(name: "Zoe", score: 80),
    Player(name: "Ada", score: 95),
    Player(name: "Bo", score: 80),
]
for (place, player) in players.sorted().enumerated() {
    print("\(place + 1). \(player)")
}
