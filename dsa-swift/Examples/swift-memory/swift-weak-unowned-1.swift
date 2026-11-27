// Generated from src/dsa/content/lessons/swift-memory/swift-weak-unowned.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Player {
    let name: String
    init(name: String) { self.name = name }
    deinit { print("\(name) freed") }
}

var strong: Player? = Player(name: "Ada")
weak var observer = strong

print(observer?.name ?? "nobody")
strong = nil
print(observer?.name ?? "nobody")
