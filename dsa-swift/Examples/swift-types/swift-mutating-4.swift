// Generated from src/dsa/content/lessons/swift-types/swift-mutating.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Player {
    var name: String
    var level: Int

    init(name: String, level: Int) {
        self.name = name
        self.level = max(1, min(level, 99))
    }
}

print(Player(name: "Ada", level: 150).level)
print(Player(name: "Bo", level: -3).level)
