// Generated from src/dsa/content/lessons/swift-generics/swift-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Describable {
    var summary: String { get }
    func describe() -> String
}

struct Book: Describable {
    var title: String
    var pages: Int

    var summary: String {
        "\(title), \(pages) pages"
    }

    func describe() -> String {
        "Book: \(summary)"
    }
}

enum Planet: Describable {
    case earth, mars

    var summary: String {
        self == .earth ? "home" : "red and dusty"
    }

    func describe() -> String {
        "Planet: \(summary)"
    }
}

print(Book(title: "Dune", pages: 412).describe())
print(Planet.mars.describe())
