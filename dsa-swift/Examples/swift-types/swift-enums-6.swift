// Generated from src/dsa/content/lessons/swift-types/swift-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Shape {
    case circle(radius: Double)
    case rectangle(width: Double, height: Double)
    case square(side: Double)

    var area: Double {
        switch self {
        case .circle(let radius):
            return 3.0 * radius * radius
        case let .rectangle(width, height):
            return width * height
        case .square(let side):
            return side * side
        }
    }
}

let shapes: [Shape] = [.circle(radius: 2), .rectangle(width: 3, height: 4), .square(side: 5)]
for shape in shapes {
    print(shape.area)
}
