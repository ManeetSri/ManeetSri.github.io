// Generated from src/dsa/design/content/lessons/sd-app-runtime/sd-runtime-launch.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// Swift globals and statics are initialised lazily, on first use, and exactly once.
// Nothing here runs at launch until someone touches it.
enum Analytics {
    static let client: String = {
        print("  configuring the analytics SDK")
        return "AnalyticsClient"
    }()
}

enum ImageCache {
    static let shared: [String: Int] = {
        print("  building the image cache")
        return [:]
    }()
}

print("main() starts")
print("first frame is on screen")
print("user taps Share, which logs an event")
print("  using \(Analytics.client)")
print("user taps Share again")
print("  using \(Analytics.client)")
print("ImageCache was never touched, so it was never built")
