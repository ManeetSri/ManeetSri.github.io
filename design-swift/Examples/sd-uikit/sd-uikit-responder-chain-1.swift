// Generated from src/dsa/design/content/lessons/sd-uikit/sd-uikit-responder-chain.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

struct Point {
    var x, y: Double
}

struct Rect {
    var x, y, width, height: Double

    func contains(_ point: Point) -> Bool {
        point.x >= x && point.x < x + width && point.y >= y && point.y < y + height
    }
}

final class Node {
    let name: String
    let frame: Rect // in its superview's coordinates
    let subviews: [Node]
    let isUserInteractionEnabled: Bool

    init(_ name: String, _ frame: Rect, interactive: Bool = true, _ subviews: [Node] = []) {
        self.name = name
        self.frame = frame
        self.isUserInteractionEnabled = interactive
        self.subviews = subviews
    }

    // UIKit's algorithm, simplified: skip me if I can't take touches; if the point isn't in my
    // bounds, nothing inside me is asked; otherwise ask subviews, front-most (last) first.
    func hitTest(_ point: Point) -> Node? {
        let bounds = Rect(x: 0, y: 0, width: frame.width, height: frame.height)
        guard isUserInteractionEnabled, bounds.contains(point) else { return nil }
        for subview in subviews.reversed() {
            let local = Point(x: point.x - subview.frame.x, y: point.y - subview.frame.y)
            if let hit = subview.hitTest(local) { return hit }
        }
        return self
    }
}

let likeButton = Node("likeButton", Rect(x: 330, y: 18, width: 44, height: 44))
let cell = Node("cell", Rect(x: 0, y: 100, width: 390, height: 80), [likeButton])
let list = Node("list", Rect(x: 0, y: 0, width: 390, height: 844), [cell])
let menu = Node("menu", Rect(x: 290, y: 36, width: 100, height: 120)) // hangs below the header
let header = Node("header", Rect(x: 0, y: 0, width: 390, height: 44), [menu])
let toast = Node("toast", Rect(x: 16, y: 760, width: 358, height: 60), interactive: false)
let window = Node("window", Rect(x: 0, y: 0, width: 390, height: 844), [list, header, toast])

for (x, y) in [(350.0, 140.0), (100, 140), (320, 40), (320, 120), (100, 780)] {
    let hit = window.hitTest(Point(x: x, y: y))?.name ?? "nothing"
    print("Tap at (\(Int(x)), \(Int(y))) → \(hit)")
}
