// Generated from src/dsa/design/content/lessons/sd-state/sd-state-global-stores.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Combine
import Observation

/// The ObservableObject way: the whole store has one objectWillChange
final class LegacyAppStore: ObservableObject {
    @Published var userName = "Maneet"
    @Published var basketCount = 0
    @Published var unreadCount = 0
}

/// The @Observable way: each property is tracked on its own
@Observable
final class AppStore {
    var userName = "Maneet"
    var basketCount = 0
    var unreadCount = 0
}

// Three views, each showing one property. Then a new message arrives.
let legacy = LegacyAppStore()
var redrawn: [String] = []
var subscriptions: Set<AnyCancellable> = []
for view in ["Profile header", "Basket badge", "Inbox badge"] {
    legacy.objectWillChange
        .sink { redrawn.append(view) }
        .store(in: &subscriptions)
}
legacy.unreadCount = 4
print("ObservableObject re-renders:", redrawn.sorted().joined(separator: ", "))

let store = AppStore()
withObservationTracking { _ = store.userName } onChange: { print("@Observable re-renders: Profile header") }
withObservationTracking { _ = store.basketCount } onChange: { print("@Observable re-renders: Basket badge") }
withObservationTracking { _ = store.unreadCount } onChange: { print("@Observable re-renders: Inbox badge") }
store.unreadCount = 4
