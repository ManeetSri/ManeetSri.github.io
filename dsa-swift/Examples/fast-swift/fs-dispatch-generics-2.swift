// Generated from src/dsa/content/lessons/fast-swift/fs-dispatch-generics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

protocol Shape {
    func area() -> Double
}

struct Square: Shape {
    var side: Double
    func area() -> Double { side * side }
}

struct Box: Shape {
    var width, height, depth, density: Double
    func area() -> Double { width * height }
}

// One concrete type per call: stored at full speed, can be specialised
func totalArea(_ shapes: [some Shape]) -> Double {
    shapes.reduce(0) { $0 + $1.area() }
}

// Any mix of types: each element in a box, every area() looked up at run time
func totalArea(mixed shapes: [any Shape]) -> Double {
    shapes.reduce(0) { $0 + $1.area() }
}

print(totalArea([Square(side: 1), Square(side: 2), Square(side: 3)]))
print(totalArea(mixed: [Square(side: 2), Box(width: 2, height: 5, depth: 1, density: 1)]))

print(MemoryLayout<Square>.size, MemoryLayout<Box>.size)
print(MemoryLayout<any Shape>.size)
