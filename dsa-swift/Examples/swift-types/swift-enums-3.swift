// Generated from src/dsa/content/lessons/swift-types/swift-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Planet: Int {
    case mercury = 1, venus, earth, mars
}

enum Suit: String {
    case hearts, spades
    case diamonds = "♦"
}

print(Planet.earth.rawValue)
print(Suit.hearts.rawValue)
print(Suit.diamonds.rawValue)
