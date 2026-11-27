// Generated from src/dsa/content/lessons/swift-types/swift-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

class Animal {
    let name: String

    init(name: String) {
        self.name = name
    }

    func sound() -> String {
        "..."
    }

    func speak() -> String {
        "\(name) says \(sound())"
    }
}

class Dog: Animal {
    override func sound() -> String {
        "Woof"
    }
}

class Cat: Animal {
    override func sound() -> String {
        "Meow"
    }
}

let pets: [Animal] = [Dog(name: "Rex"), Cat(name: "Tom"), Animal(name: "Generic")]
for pet in pets {
    print(pet.speak())
}
