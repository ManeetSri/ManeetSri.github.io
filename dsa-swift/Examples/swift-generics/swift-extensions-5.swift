// Generated from src/dsa/content/lessons/swift-generics/swift-extensions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Greeter {
    var name: String { get }
    func greet() -> String
}

extension Greeter {
    func greet() -> String {
        "Hello, I'm \(name)."
    }

    func greetTwice() -> String {
        greet() + " " + greet()
    }
}

struct Person: Greeter {
    var name: String
}

struct Robot: Greeter {
    var name: String

    func greet() -> String {
        "BEEP. UNIT \(name) ONLINE."
    }
}

print(Person(name: "Maneet").greet())
print(Robot(name: "R2").greet())
print(Person(name: "Ada").greetTwice())
