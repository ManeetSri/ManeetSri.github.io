// Generated from src/dsa/design/content/lessons/sd-swiftui/sd-swiftui-updates.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Observation

@Observable
final class Basket {
    var title = "Weekly shop"
    var count = 0
}

let basket = Basket()

// Stand-ins for two views' bodies: each reads one property
func render(_ name: String, reading read: () -> Void) {
    withObservationTracking(read) {
        print("\(name) needs a new body")
    }
}

render("Header") { _ = basket.title }
render("Badge") { _ = basket.count }

print("count changes")
basket.count += 1
print("count changes again")
basket.count += 1
print("title changes")
basket.title = "Party"
