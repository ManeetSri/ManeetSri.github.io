// Generated from src/dsa/design/content/lessons/sd-solid/sd-solid-lsp.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

class Rectangle {
    var width: Double
    var height: Double

    init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    var area: Double { width * height }
}

final class Square: Rectangle {
    init(side: Double) {
        super.init(width: side, height: side)
    }

    override var width: Double { didSet { if height != width { height = width } } }
    override var height: Double { didSet { if width != height { width = height } } }
}

// Written against Rectangle's contract: each side can be set on its own
func resizeBanner(_ banner: Rectangle) -> Double {
    banner.width = 320
    banner.height = 50
    return banner.area
}

print(resizeBanner(Rectangle(width: 1, height: 1)))
print(resizeBanner(Square(side: 1)))
