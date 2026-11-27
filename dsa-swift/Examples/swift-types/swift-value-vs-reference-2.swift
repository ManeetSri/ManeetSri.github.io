// Generated from src/dsa/content/lessons/swift-types/swift-value-vs-reference.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

class PointObject {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

var a = PointObject(x: 1, y: 2)
var b = a
b.x = 100

print("a.x =", a.x)
print("b.x =", b.x)
