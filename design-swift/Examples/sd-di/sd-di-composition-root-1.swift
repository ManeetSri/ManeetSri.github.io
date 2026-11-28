// Generated from src/dsa/design/content/lessons/sd-di/sd-di-composition-root.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

var apiClientsBuilt = 0

struct AppConfig {
    enum Environment {
        case production, staging, uiTesting
    }

    var environment: Environment

    /// Launch arguments are how a UI test chooses the root: XCUIApplication().launchArguments = ["-ui-testing"]
    init(arguments: [String]) {
        if arguments.contains("-ui-testing") {
            environment = .uiTesting
        } else if arguments.contains("-staging") {
            environment = .staging
        } else {
            environment = .production
        }
    }
}

protocol TripsLoading: Sendable {
    func trips() async -> [String]
}

final class LiveTripsAPI: TripsLoading {
    let host: String

    @MainActor init(host: String) {
        self.host = host
        apiClientsBuilt += 1
    }

    func trips() async -> [String] {
        host.hasPrefix("staging") ? ["Lisbon (staging data)"] : ["Lisbon"]
    }
}

struct FixtureTrips: TripsLoading {
    func trips() async -> [String] { ["Fixture: Porto", "Fixture: Seville"] }
}

@MainActor final class TripsModel {
    private let loader: any TripsLoading
    private(set) var trips: [String] = []

    init(loader: any TripsLoading) {
        self.loader = loader
    }

    func load() async {
        trips = await loader.trips()
    }
}

@MainActor final class AppRoot {
    private let trips: any TripsLoading

    init(config: AppConfig) {
        // The one switch on configuration in the whole app
        switch config.environment {
        case .production: trips = LiveTripsAPI(host: "api.example.com")
        case .staging: trips = LiveTripsAPI(host: "staging.api.example.com")
        case .uiTesting: trips = FixtureTrips()
        }
    }

    // A factory: a new model per screen, sharing the root's one API client
    func makeTripsModel() -> TripsModel {
        TripsModel(loader: trips)
    }
}

let staging = AppRoot(config: AppConfig(arguments: ["TravelApp", "-staging"]))
let first = staging.makeTripsModel()
let second = staging.makeTripsModel()
await first.load()
await second.load()
print("API clients built:", apiClientsBuilt)
print("each screen has its own model:", first !== second)
print("staging trips:", first.trips)

let uiTest = AppRoot(config: AppConfig(arguments: ["TravelApp", "-ui-testing"]))
let fixtureModel = uiTest.makeTripsModel()
await fixtureModel.load()
print("UI-test trips:", fixtureModel.trips)
print("API clients built:", apiClientsBuilt)
