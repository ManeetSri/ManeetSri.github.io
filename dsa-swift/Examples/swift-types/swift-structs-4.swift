// Generated from src/dsa/content/lessons/swift-types/swift-structs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Rectangle {
    var width: Int
    var height: Int

    var area: Int {
        width * height
    }

    var isSquare: Bool {
        width == height
    }
}

var box = Rectangle(width: 4, height: 3)
print(box.area)
print(box.isSquare)
box.width = 3
print(box.area)
print(box.isSquare)
