// Generated from src/dsa/content/lessons/swift-tooling/swift-assertions-defer.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Move {
    case up, down
}

func move(from letter: Character) -> Move {
    switch letter {
    case "U": return .up
    case "D": return .down
    default: fatalError("Unexpected move: \(letter)")
    }
}

print(move(from: "U"))
print(move(from: "D"))
