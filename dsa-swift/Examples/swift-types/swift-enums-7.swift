// Generated from src/dsa/content/lessons/swift-types/swift-enums.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

enum Shape {
    case circle(radius: Double)
    case square(side: Double)
}

let item = Shape.square(side: 3)
if case .square(let side) = item {
    print("A square with side \(side)")
}
if case .circle = item {
    print("A circle")
} else {
    print("Not a circle")
}
