// Generated from src/dsa/content/lessons/swift-types/swift-observers-static.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct ScoreTracker {
    private(set) var best = 0
    var current = 0 {
        didSet {
            if current > best {
                best = current
            }
        }
    }
}

var game = ScoreTracker()
for score in [12, 40, 7, 33] {
    game.current = score
}
print(game.current, game.best)
