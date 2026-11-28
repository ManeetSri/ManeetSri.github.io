// Kata: A navigation reducer for a tabbed app (D20 · NavigationStack and NavigationPath, State-driven navigation)
import Foundation

public enum NavigationPathReducer {
    /// The app's four tabs. Each keeps its own stack of screens.
    public enum Tab: String, CaseIterable, Hashable, Sendable {
        case home, search, basket, account
    }

    /// A screen pushed above a tab's root, by id
    public enum Screen: Hashable, Sendable {
        case category(String)
        case product(Int)
        case reviews(productID: Int)
        case orders
        case order(String)
        case settings
    }

    /// What can be presented over the tabs. At most one at a time.
    public enum Sheet: Hashable, Sendable {
        case signIn
        case share(productID: Int)
    }

    /// A destination from outside the app: a tab, and the screens to show above its root
    public struct DeepLink: Hashable, Sendable {
        public var tab: Tab
        public var screens: [Screen]

        public init(tab: Tab, screens: [Screen] = []) {
            self.tab = tab
            self.screens = screens
        }
    }

    /// One window's navigation, as a value
    public struct State: Equatable, Sendable {
        public var selectedTab: Tab
        /// Every tab always has an entry here (an empty array is its root), so states built in
        /// different ways compare equal. Set a path to `[]`; never remove a key.
        public var paths: [Tab: [Screen]]
        public var sheet: Sheet?
        public var isSignedIn: Bool
        /// A link to the account tab, waiting for sign-in to finish
        public var pendingLink: DeepLink?

        public init(selectedTab: Tab = .home, paths: [Tab: [Screen]] = [:], sheet: Sheet? = nil, isSignedIn: Bool = false, pendingLink: DeepLink? = nil) {
            self.selectedTab = selectedTab
            self.paths = Dictionary(uniqueKeysWithValues: Tab.allCases.map { ($0, paths[$0] ?? []) })
            self.sheet = sheet
            self.isSignedIn = isSignedIn
            self.pendingLink = pendingLink
        }

        /// The selected tab's path
        public var currentPath: [Screen] {
            paths[selectedTab] ?? []
        }
    }

    /// Everything that can change navigation: taps, system events and links
    public enum Action: Equatable, Sendable {
        /// Push onto the selected tab
        case push(Screen)
        /// Back, on the selected tab
        case pop
        case popToRoot
        /// Replace the selected tab's whole path
        case replace([Screen])
        /// The user tapped a tab, possibly the one already selected
        case select(Tab)
        case present(Sheet)
        case dismiss
        /// A link, notification or widget asked for a destination
        case open(DeepLink)
        case signedIn
        case signedOut
    }

    /// Applies `action` to `state`, following the rules in the kata's statement
    public static func reduce(_ state: inout State, _ action: Action) {
        // Write your solution here, then run:
        // swift test --filter NavigationPathReducerTests
    }
}
