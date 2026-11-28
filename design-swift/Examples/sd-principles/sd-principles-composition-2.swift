// Generated from src/dsa/design/content/lessons/sd-principles/sd-principles-composition.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol ScreenTracking {
    var screenName: String { get }
}

extension ScreenTracking {
    func trackAppearance() -> String { "viewed \(screenName)" }   // not a requirement
}

struct OrdersScreen: ScreenTracking {
    var screenName: String { "orders" }
    func trackAppearance() -> String { "viewed orders, with filters" }
}

let screen = OrdersScreen()
let tracked: any ScreenTracking = screen
print(screen.trackAppearance())
print(tracked.trackAppearance())
