// Generated from src/dsa/content/lessons/swift-generics/swift-extensions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Describable {
    func describe() -> String
}

struct Point {
    var x: Int
    var y: Int
}

extension Point: Describable {
    func describe() -> String {
        "(\(x), \(y))"
    }
}

extension Int: Describable {
    func describe() -> String {
        "the number \(self)"
    }
}

let things: [any Describable] = [Point(x: 3, y: 4), 42]
for thing in things {
    print(thing.describe())
}
