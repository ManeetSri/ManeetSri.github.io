// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-singleton-alternatives.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Clock: Sendable {
    var now: @Sendable () -> Date

    static let live = Clock(now: { Date() })
    static func fixed(_ seconds: TimeInterval) -> Clock {
        Clock(now: { Date(timeIntervalSince1970: seconds) })
    }
}

enum Current {
    // A task-local: one default for the whole app, overridable for a scope and its child tasks
    @TaskLocal static var clock = Clock.live
}

struct Coupon {
    let expires: Date
    var isValid: Bool { Current.clock.now() < expires }
}

let coupon = Coupon(expires: Date(timeIntervalSince1970: 1_000))

Current.$clock.withValue(.fixed(999)) {
    print("one second before expiry:", coupon.isValid)
}
Current.$clock.withValue(.fixed(1_000)) {
    print("at expiry:", coupon.isValid)
}

await Current.$clock.withValue(.fixed(500)) {
    let child = Task { coupon.isValid }
    let detached = Task.detached { Current.clock.now() == Date(timeIntervalSince1970: 500) }
    print("child task sees the override:", await child.value)
    print("detached task sees the override:", await detached.value)
}
