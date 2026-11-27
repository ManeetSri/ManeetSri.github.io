// Generated from src/dsa/content/lessons/fast-swift/fs-dispatch-generics.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

class Shape {
    func describe() -> String { "a shape" }
}

final class Circle: Shape {
    override func describe() -> String { "a circle" }
}

let shapes: [Shape] = [Shape(), Circle()]
for shape in shapes {
    print(shape.describe())      // which describe()? decided at run time
}
