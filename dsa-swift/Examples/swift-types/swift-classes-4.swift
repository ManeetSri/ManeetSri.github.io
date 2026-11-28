// Generated from src/dsa/content/lessons/swift-types/swift-classes.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

class Vehicle {
    let wheels: Int

    init(wheels: Int) {
        self.wheels = wheels
    }

    func summary() -> String {
        "\(wheels) wheels"
    }
}

class Bicycle: Vehicle {
    let hasBell: Bool

    init(hasBell: Bool) {
        self.hasBell = hasBell
        super.init(wheels: 2)
    }

    override func summary() -> String {
        super.summary() + (hasBell ? ", with a bell" : ", no bell")
    }
}

print(Bicycle(hasBell: true).summary())
