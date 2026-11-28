// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-some-any.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol Shape { func area() -> Double }
protocol Named { var name: String { get } }
protocol Cell: AnyObject { func reload() }

struct Square: Shape {
    var side: Double
    func area() -> Double { side * side }
}

struct Panel: Shape {
    var x, y, width, height: Double
    func area() -> Double { width * height }
}

print("Square:", MemoryLayout<Square>.size)
print("Panel:", MemoryLayout<Panel>.size)
print("any Shape:", MemoryLayout<any Shape>.size)
print("any Shape & Named:", MemoryLayout<any Shape & Named>.size)
print("any Cell:", MemoryLayout<any Cell>.size)
print("any Error:", MemoryLayout<any Error>.size)
