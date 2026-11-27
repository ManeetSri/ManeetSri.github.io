// Generated from src/dsa/content/lessons/swift-memory/swift-arc.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Player {
    let name: String

    init(name: String) {
        self.name = name
        print("\(name) created")
    }

    deinit {
        print("\(name) freed")
    }
}

print("before the scope")
do {
    let player = Player(name: "Ada")
    print("playing as \(player.name)")
}
print("after the scope")
