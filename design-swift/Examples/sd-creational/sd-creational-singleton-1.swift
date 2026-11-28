// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-singleton.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

final class Analytics: Sendable {
    static let shared = Analytics()
    private init() { print("Analytics created") }

    func track(_ event: String) { print("track \(event)") }
}

print("App launched")
print("First screen shown")
Analytics.shared.track("tap")
Analytics.shared.track("scroll")
