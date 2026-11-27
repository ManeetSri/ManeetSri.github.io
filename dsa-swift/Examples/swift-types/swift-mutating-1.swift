// Generated from src/dsa/content/lessons/swift-types/swift-mutating.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

struct Point {
    var x: Int
    var y: Int

    mutating func move(dx: Int, dy: Int) {
        x += dx
        y += dy
    }
}

var robot = Point(x: 0, y: 0)
robot.move(dx: 2, dy: 1)
robot.move(dx: -1, dy: 4)
print(robot)
