// Generated from src/dsa/content/lessons/swift-memory/swift-arc.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Player {
    let name: String
    init(name: String) { self.name = name }
    deinit { print("\(name) freed") }
}

var first: Player? = Player(name: "Bo")    // count: 1
var second = first                         // count: 2
first = nil                                // count: 1
print("first is nil")
second = nil                               // count: 0, so Bo is freed
print("second is nil")
