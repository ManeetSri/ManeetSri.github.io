// Generated from src/dsa/content/lessons/swift-types/swift-identity.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Robot {
    var name: String

    init(name: String) {
        self.name = name
    }
}

let first = Robot(name: "R2")
let twin = Robot(name: "R2")
let nickname = first

print(first === nickname)
print(first === twin)
print(first !== twin)
