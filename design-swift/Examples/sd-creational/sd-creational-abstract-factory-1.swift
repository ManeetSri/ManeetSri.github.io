// Generated from src/dsa/design/content/lessons/sd-creational/sd-creational-abstract-factory.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

// The products: what screens need, as protocols
protocol AccountAPI: Sendable {
    func displayName(for userID: String) -> String
}

protocol TokenStore: Sendable {
    var signedInUserID: String? { get }
}

protocol Analytics: Sendable {
    func track(_ event: String) -> String
}

// The abstract factory: one method per product
protocol DependencyFactory: Sendable {
    var name: String { get }
    func makeAccountAPI() -> any AccountAPI
    func makeTokenStore() -> any TokenStore
    func makeAnalytics() -> any Analytics
}

// The live family
struct ServerAccountAPI: AccountAPI {
    func displayName(for userID: String) -> String { "(GET /users/\(userID) on api.example.com)" }
}
struct KeychainTokenStore: TokenStore {
    var signedInUserID: String? { "user-8812" }
}
struct ServerAnalytics: Analytics {
    func track(_ event: String) -> String { "sent \(event)" }
}
struct LiveFactory: DependencyFactory {
    let name = "live"
    func makeAccountAPI() -> any AccountAPI { ServerAccountAPI() }
    func makeTokenStore() -> any TokenStore { KeychainTokenStore() }
    func makeAnalytics() -> any Analytics { ServerAnalytics() }
}

// The demo family, for App Store review: canned data, a demo user, no real analytics
struct CannedAccountAPI: AccountAPI {
    func displayName(for userID: String) -> String { userID == "demo" ? "Demo Reviewer" : "Unknown" }
}
struct DemoTokenStore: TokenStore {
    var signedInUserID: String? { "demo" }
}
struct DroppingAnalytics: Analytics {
    func track(_ event: String) -> String { "dropped \(event)" }
}
struct DemoFactory: DependencyFactory {
    let name = "demo"
    func makeAccountAPI() -> any AccountAPI { CannedAccountAPI() }
    func makeTokenStore() -> any TokenStore { DemoTokenStore() }
    func makeAnalytics() -> any Analytics { DroppingAnalytics() }
}

// The one decision, made once at launch
func chooseFactory(launchArguments: [String]) -> any DependencyFactory {
    launchArguments.contains("-demo") ? DemoFactory() : LiveFactory()
}

// A screen sees only protocols, so it can't mix families
func profileHeader(using factory: any DependencyFactory) -> String {
    let store = factory.makeTokenStore()
    let api = factory.makeAccountAPI()
    let analytics = factory.makeAnalytics()
    guard let user = store.signedInUserID else { return "Signed out" }
    return "\(factory.name): \(api.displayName(for: user)), \(analytics.track("profile_viewed"))"
}

print(profileHeader(using: chooseFactory(launchArguments: ["MyApp"])))
print(profileHeader(using: chooseFactory(launchArguments: ["MyApp", "-demo"])))
