// Reference solution: A navigation reducer for a tabbed app. One pure function over a value: tab actions
// change only the selected tab's path, and only when no sheet hides it; a deep link dismisses, selects
// and replaces, leaving other tabs alone; links to the account wait behind sign-in as a pending link.
import Foundation

public enum NavigationPathReducer {
    public enum Tab: String, CaseIterable, Hashable, Sendable {
        case home, search, basket, account
    }

    public enum Screen: Hashable, Sendable {
        case category(String)
        case product(Int)
        case reviews(productID: Int)
        case orders
        case order(String)
        case settings
    }

    public enum Sheet: Hashable, Sendable {
        case signIn
        case share(productID: Int)
    }

    public struct DeepLink: Hashable, Sendable {
        public var tab: Tab
        public var screens: [Screen]

        public init(tab: Tab, screens: [Screen] = []) {
            self.tab = tab
            self.screens = screens
        }
    }

    public struct State: Equatable, Sendable {
        public var selectedTab: Tab
        public var paths: [Tab: [Screen]]
        public var sheet: Sheet?
        public var isSignedIn: Bool
        public var pendingLink: DeepLink?

        public init(selectedTab: Tab = .home, paths: [Tab: [Screen]] = [:], sheet: Sheet? = nil, isSignedIn: Bool = false, pendingLink: DeepLink? = nil) {
            self.selectedTab = selectedTab
            self.paths = Dictionary(uniqueKeysWithValues: Tab.allCases.map { ($0, paths[$0] ?? []) })
            self.sheet = sheet
            self.isSignedIn = isSignedIn
            self.pendingLink = pendingLink
        }

        public var currentPath: [Screen] {
            paths[selectedTab] ?? []
        }
    }

    public enum Action: Equatable, Sendable {
        case push(Screen)
        case pop
        case popToRoot
        case replace([Screen])
        case select(Tab)
        case present(Sheet)
        case dismiss
        case open(DeepLink)
        case signedIn
        case signedOut
    }

    public static func reduce(_ state: inout State, _ action: Action) {
        switch action {
        case .push, .pop, .popToRoot, .replace, .select:
            // A sheet covers the tabs: changing them now would happen out of sight
            guard state.sheet == nil else { return }
            reduceTab(&state, action)

        case .present(let sheet):
            guard state.sheet == nil else { return }
            state.sheet = sheet

        case .dismiss:
            if state.sheet == .signIn { state.pendingLink = nil }   // the user gave up on signing in
            state.sheet = nil

        case .open(let link):
            open(link, in: &state)

        case .signedIn:
            state.isSignedIn = true
            if state.sheet == .signIn { state.sheet = nil }
            if let link = state.pendingLink {
                state.pendingLink = nil
                open(link, in: &state)
            }

        case .signedOut:
            state.isSignedIn = false
            state.paths[.account] = []
            state.pendingLink = nil
            state.sheet = nil
        }
    }

    private static func reduceTab(_ state: inout State, _ action: Action) {
        let tab = state.selectedTab
        switch action {
        case .push(let screen):
            guard state.paths[tab]?.last != screen else { return }   // a double tap pushes once
            state.paths[tab, default: []].append(screen)
        case .pop:
            _ = state.paths[tab]?.popLast()
        case .popToRoot:
            state.paths[tab] = []
        case .replace(let screens):
            state.paths[tab] = screens
        case .select(let newTab):
            if newTab == tab {
                state.paths[tab] = []   // tapping the selected tab again goes to its root
            } else {
                state.selectedTab = newTab
            }
        default:
            break
        }
    }

    private static func open(_ link: DeepLink, in state: inout State) {
        if link.tab == .account && !state.isSignedIn {
            // Hold the link, ask for sign-in, and change nothing else until it succeeds
            state.pendingLink = link
            state.sheet = .signIn
            return
        }
        state.pendingLink = nil
        state.sheet = nil
        state.selectedTab = link.tab
        state.paths[link.tab] = link.screens
    }
}
