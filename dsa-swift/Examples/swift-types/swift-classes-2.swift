// Generated from src/dsa/content/lessons/swift-types/swift-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

class Animal {
    let name: String

    init(name: String) {
        self.name = name
    }

    func describe() -> String {
        "\(name) is an animal"
    }
}

class Dog: Animal {
    var tricks: [String] = []

    func learn(_ trick: String) {
        tricks.append(trick)
    }
}

let rex = Dog(name: "Rex")
rex.learn("sit")
print(rex.name)
print(rex.describe())
print(rex.tricks)
