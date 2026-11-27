// Generated from src/dsa/content/lessons/swift-generics/swift-standard-protocols.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Username: Equatable {
    var text: String

    static func == (lhs: Username, rhs: Username) -> Bool {
        lhs.text.lowercased() == rhs.text.lowercased()
    }
}

print(Username(text: "Maneet") == Username(text: "MANEET"))
print(Username(text: "Maneet") == Username(text: "Ada"))
