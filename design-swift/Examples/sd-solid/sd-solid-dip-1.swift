// Generated from src/dsa/design/content/lessons/sd-solid/sd-solid-dip.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The policy declares what it needs, here as a struct of closures
struct ReviewDependencies {
    var loadCount: () -> Int
    var saveCount: (Int) -> Void
    var appVersion: () -> String
    var lastPromptedVersion: () -> String?
    var recordPrompt: (String) -> Void
    var requestReview: () -> Void
}

struct ReviewPolicy {
    let dependencies: ReviewDependencies

    func orderCompleted() {
        let count = dependencies.loadCount() + 1
        dependencies.saveCount(count)
        let version = dependencies.appVersion()
        guard count >= 3, dependencies.lastPromptedVersion() != version else { return }
        dependencies.requestReview()
        dependencies.recordPrompt(version)
    }
}

// A test supplies the details as plain values: no UserDefaults, no StoreKit
var count = 0
var lastVersion: String?
var prompts = 0
let policy = ReviewPolicy(dependencies: ReviewDependencies(
    loadCount: { count },
    saveCount: { count = $0 },
    appVersion: { "2.4" },
    lastPromptedVersion: { lastVersion },
    recordPrompt: { lastVersion = $0 },
    requestReview: { prompts += 1 }
))
for order in 1...4 {
    policy.orderCompleted()
    print("order \(order): prompts so far \(prompts)")
}
