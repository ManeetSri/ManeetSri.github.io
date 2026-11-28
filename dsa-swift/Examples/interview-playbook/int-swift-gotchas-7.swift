// Generated from src/dsa/content/lessons/interview-playbook/int-swift-gotchas.mdx. Edit the lesson, then run
// `npm run dsa:examples` to update this file. Run it from dsa-swift/ with: swift <this file>

final class Counter {
    var value = 0
}
let shared = Array(repeating: Counter(), count: 3)    // one Counter, three references to it
shared[0].value = 7
print(shared.map(\.value))
let separate = (0..<3).map { _ in Counter() }         // three Counters
separate[0].value = 7
print(separate.map(\.value))

struct Point {
    var x = 0
}
var points = [Point(), Point()]
for point in points {
    var moved = point                                 // a copy: the array doesn't change
    moved.x = 5
}
print(points.map(\.x))
for index in points.indices {
    points[index].x = 5                               // writes into the array itself
}
print(points.map(\.x))
