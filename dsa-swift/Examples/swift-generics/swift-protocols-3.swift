// Generated from src/dsa/content/lessons/swift-generics/swift-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Describable {
    func describe() -> String
}

struct Book: Describable {
    var title: String
    func describe() -> String { "Book: \(title)" }
}

struct Song: Describable {
    var name: String
    var seconds: Int
    func describe() -> String { "Song: \(name) (\(seconds)s)" }
}

func printAll(_ items: [any Describable]) {
    for item in items {
        print(item.describe())
    }
}

printAll([Book(title: "Dune"), Song(name: "Blue", seconds: 190), Book(title: "Emma")])
