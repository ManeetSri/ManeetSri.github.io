// Generated from src/dsa/content/lessons/swift-types/swift-identity.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Robot: Equatable {
    var name: String

    init(name: String) {
        self.name = name
    }

    static func == (lhs: Robot, rhs: Robot) -> Bool {
        lhs.name == rhs.name
    }
}

let first = Robot(name: "R2")
let twin = Robot(name: "R2")

print(first == twin)
print(first === twin)
