// Generated from src/dsa/design/content/lessons/sd-swift-design/sd-swift-design-protocols.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol TrackedScreen {
    var screenName: String { get }
}

extension TrackedScreen {
    var screenName: String { String(describing: Self.self) }
    // Not a requirement: a convenience every screen gets
    var category: String { "general" }
    func event() -> String { "\(category)/\(screenName)" }
}

struct CheckoutScreen: TrackedScreen {
    var screenName: String { "checkout" }
    var category: String { "commerce" }   // looks like an override; isn't one
}

struct SettingsScreen: TrackedScreen {}

let checkout = CheckoutScreen()
print(checkout.category)
print(checkout.event())

let screens: [any TrackedScreen] = [CheckoutScreen(), SettingsScreen()]
for screen in screens {
    print(screen.event())
}
