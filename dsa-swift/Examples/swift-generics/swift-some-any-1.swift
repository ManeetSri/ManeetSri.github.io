// Generated from src/dsa/content/lessons/swift-generics/swift-some-any.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Shape {
    func area() -> Double
}

struct Square: Shape {
    var side: Double
    func area() -> Double { side * side }
}

struct Rectangle: Shape {
    var width: Double
    var height: Double
    func area() -> Double { width * height }
}

var current: any Shape = Square(side: 3)
print(current.area())
current = Rectangle(width: 2, height: 5)
print(current.area())

let mixed: [any Shape] = [Square(side: 1), Rectangle(width: 2, height: 3), Square(side: 2)]
let total = mixed.reduce(0) { $0 + $1.area() }
print(total)
