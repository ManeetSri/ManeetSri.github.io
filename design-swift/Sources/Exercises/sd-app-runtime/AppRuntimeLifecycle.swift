// Kata: App lifecycle machine (D16 · App states, UIApplicationDelegate and UISceneDelegate)
import Foundation

public enum AppRuntimeLifecycle {
    /// Where the app is in its lifecycle
    public enum Phase: Sendable, Equatable {
        case notRunning
        case inactive
        case active
        case background
        case suspended
    }

    /// What iOS tells the app, or does to it
    public enum Event: Sendable, Equatable {
        /// The user opened the app: the process starts, and a scene is on its way
        case launch
        /// iOS started the app straight into the background: a BGTask, a silent push, a location event
        case launchInBackground
        case didBecomeActive
        case willResignActive
        case didEnterBackground
        case willEnterForeground
        /// The save started on entering the background has finished
        case saveFinished
        /// The background task's expiration handler ran: time is up
        case backgroundTimeExpired
        /// iOS froze the process
        case suspend
        /// The process was killed: jetsam, a force quit, a crash. No code runs.
        case terminate
    }

    /// Work the app does in response to an event, in the order it should happen
    public enum Effect: Sendable, Equatable {
        /// Build the app-wide services: networking, storage, analytics
        case configureServices
        /// Timers, animations, a camera preview: work only worth doing while the user is interacting
        case startLiveUpdates
        case stopLiveUpdates
        /// Fetch fresh content for the screen
        case refreshContent
        /// `UIApplication.beginBackgroundTask`: ask for time to finish the save
        case beginBackgroundTask
        case saveState
        /// Drop caches that can be rebuilt, so the suspended app is less likely to be killed
        case releaseCaches
        /// `UIApplication.endBackgroundTask`
        case endBackgroundTask
    }

    public struct Machine: Sendable {
        public private(set) var phase: Phase = .notRunning
        /// Content refreshed less than this long ago isn't refreshed again on activation
        public let refreshInterval: Duration

        public init(refreshInterval: Duration = .seconds(15 * 60)) {
            self.refreshInterval = refreshInterval
        }

        /// Moves to the next phase for `event`, which happened at `time`, and returns the work to do.
        /// An event that makes no sense in the current phase is ignored: no effects, no change.
        public mutating func handle(_ event: Event, at time: Duration) -> [Effect] {
            // Write your solution here, then run:
            // swift test --filter AppRuntimeLifecycleTests
            return []
        }
    }
}
