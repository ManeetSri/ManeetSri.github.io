// Generated from src/dsa/content/lessons/swift-generics/swift-extensions.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

extension Int {
    var isEven: Bool {
        self % 2 == 0
    }

    func squared() -> Int {
        self * self
    }

    mutating func double() {
        self *= 2
    }
}

print(7.isEven)
print(12.squared())
var score = 21
score.double()
print(score)
