// Generated from src/dsa/design/content/lessons/sd-di/sd-di-dependency-values.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

struct Dependencies: Sendable {
    var now: @Sendable () -> Date = { Date() }
    var region = "live"

    @TaskLocal static var current = Dependencies()
}

func withDependencies<R>(_ update: (inout Dependencies) -> Void, operation: () -> R) -> R {
    var values = Dependencies.current
    update(&values)
    return Dependencies.$current.withValue(values, operation: operation)
}

/// Captures its dependencies when it's created, as @Dependency does
final class CouponModel: Sendable {
    private let now: @Sendable () -> Date
    let expires = Date(timeIntervalSince1970: 1_000)

    init() {
        now = Dependencies.current.now
    }

    var isValid: Bool { now() < expires }
}

let beforeExpiry = withDependencies {
    $0.now = { Date(timeIntervalSince1970: 999) }
} operation: {
    CouponModel()
}
print("created inside the scope, used outside:", beforeExpiry.isValid)

var testing = Dependencies.current
testing.region = "test-region"
await Dependencies.$current.withValue(testing) {
    let child = Task { Dependencies.current.region }
    let detached = Task.detached { Dependencies.current.region }
    print("child task:", await child.value)
    print("detached task:", await detached.value)
}
print("after the scope:", Dependencies.current.region)
