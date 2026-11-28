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

func describe(_ shape: some Shape) -> String {
    "A shape with area \(shape.area())"
}

print(describe(Square(side: 2)))
print(describe(Rectangle(width: 1, height: 7)))
