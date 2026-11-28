// Generated from src/dsa/content/lessons/swift-generics/swift-some-any.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Shape {
    func area() -> Double
}

struct Square: Shape {
    var side: Double
    func area() -> Double { side * side }
}

func makeTile() -> some Shape {
    Square(side: 4)
}

let tile = makeTile()
print(tile.area())
