// Generated from src/dsa/content/lessons/swift-types/swift-mutating.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Rectangle {
    var width: Int
    var height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    init(side: Int) {
        self.init(width: side, height: side)
    }
}

let wide = Rectangle(width: 5, height: 2)
let square = Rectangle(side: 3)
print(wide.width, wide.height)
print(square.width, square.height)
