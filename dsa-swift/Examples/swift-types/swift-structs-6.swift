// Generated from src/dsa/content/lessons/swift-types/swift-structs.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Double
    var y: Double

    func distance(to other: Point) -> Double {
        let dx = other.x - x
        let dy = other.y - y
        return (dx * dx + dy * dy).squareRoot()
    }

    func describe() -> String {
        "(\(x), \(y))"
    }
}

let home = Point(x: 0, y: 0)
let shop = Point(x: 3, y: 4)
print(home.distance(to: shop))
print(shop.describe())
