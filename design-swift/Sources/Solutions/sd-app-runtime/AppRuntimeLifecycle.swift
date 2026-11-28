// Reference solution: App lifecycle machine. A pure state machine: the phase and two facts the process
// remembers (whether a background task is open, and when content was last refreshed). Every rule lives
// in one switch over (phase, event), so an impossible event falls through to "ignore" by construction.
import Foundation

public enum AppRuntimeLifecycle {
    public enum Phase: Sendable, Equatable {
        case notRunning
        case inactive
        case active
        case background
        case suspended
    }

    public enum Event: Sendable, Equatable {
        case launch
        case launchInBackground
        case didBecomeActive
        case willResignActive
        case didEnterBackground
        case willEnterForeground
        case saveFinished
        case backgroundTimeExpired
        case suspend
        case terminate
    }

    public enum Effect: Sendable, Equatable {
        case configureServices
        case startLiveUpdates
        case stopLiveUpdates
        case refreshContent
        case beginBackgroundTask
        case saveState
        case releaseCaches
        case endBackgroundTask
    }

    public struct Machine: Sendable {
        public private(set) var phase: Phase = .notRunning
        public let refreshInterval: Duration

        // Process memory: both are lost when the process dies
        private var backgroundTaskOpen = false
        private var lastRefresh: Duration?

        public init(refreshInterval: Duration = .seconds(15 * 60)) {
            self.refreshInterval = refreshInterval
        }

        public mutating func handle(_ event: Event, at time: Duration) -> [Effect] {
            switch (phase, event) {
            case (.notRunning, .launch):
                phase = .inactive
                return [.configureServices]

            case (.notRunning, .launchInBackground):
                phase = .background
                return [.configureServices]

            case (.inactive, .didBecomeActive):
                phase = .active
                var effects: [Effect] = [.startLiveUpdates]
                if isStale(at: time) {
                    lastRefresh = time
                    effects.append(.refreshContent)
                }
                return effects

            case (.active, .willResignActive):
                phase = .inactive
                return [.stopLiveUpdates]

            case (.inactive, .didEnterBackground):
                phase = .background
                // Ask for time before starting the work it protects, and never hold two tasks
                var effects: [Effect] = []
                if !backgroundTaskOpen {
                    backgroundTaskOpen = true
                    effects.append(.beginBackgroundTask)
                }
                return effects + [.saveState, .releaseCaches]

            case (.background, .willEnterForeground), (.suspended, .willEnterForeground):
                phase = .inactive
                return []

            case (_, .saveFinished) where backgroundTaskOpen,
                 (_, .backgroundTimeExpired) where backgroundTaskOpen:
                backgroundTaskOpen = false
                return [.endBackgroundTask]

            case (.background, .suspend) where !backgroundTaskOpen:
                phase = .suspended
                return []

            case (let current, .terminate) where current != .notRunning:
                // Nothing runs when a process is killed, and everything it remembered is gone
                self = Machine(refreshInterval: refreshInterval)
                return []

            default:
                return []
            }
        }

        private func isStale(at time: Duration) -> Bool {
            guard let lastRefresh else { return true }
            return time - lastRefresh >= refreshInterval
        }
    }
}
