import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct NavigationPathReducerTests {
    typealias Reducer = NavigationPathReducer
    typealias State = NavigationPathReducer.State
    typealias Action = NavigationPathReducer.Action
    typealias DeepLink = NavigationPathReducer.DeepLink

    /// Applies each action in turn, as the app would
    private func run(_ actions: [Action], from start: State = State()) -> State {
        var state = start
        for action in actions {
            Reducer.reduce(&state, action)
        }
        return state
    }

    // MARK: - Tab actions

    @Test("Pushes go onto the selected tab only")
    func push() {
        let state = run([.push(.category("shoes")), .push(.product(7))])
        #expect(state.paths[.home] == [.category("shoes"), .product(7)])
        #expect(state.paths[.search] == [])
        #expect(state.currentPath == [.category("shoes"), .product(7)])
    }

    @Test("A double tap pushes once, but a screen may appear again further up")
    func duplicatePush() {
        #expect(run([.push(.product(7)), .push(.product(7))]).currentPath == [.product(7)])
        let browsing = run([.push(.product(7)), .push(.reviews(productID: 7)), .push(.product(7))])
        #expect(browsing.currentPath == [.product(7), .reviews(productID: 7), .product(7)])
    }

    @Test("Pop removes the top screen and does nothing at the root")
    func pop() {
        #expect(run([.push(.product(7)), .push(.reviews(productID: 7)), .pop]).currentPath == [.product(7)])
        #expect(run([.pop]) == State())
        #expect(run([.push(.product(7)), .pop, .pop]).currentPath == [])
    }

    @Test("Pop to root and replace change the whole selected path")
    func popToRootAndReplace() {
        let deep = run([.push(.category("shoes")), .push(.product(7)), .push(.reviews(productID: 7))])
        #expect(run([.popToRoot], from: deep).currentPath == [])
        #expect(run([.replace([.orders, .order("A1B2C3")])], from: deep).currentPath == [.orders, .order("A1B2C3")])
        #expect(run([.replace([])], from: deep).currentPath == [])
    }

    @Test("Switching tabs keeps every tab's path")
    func switchTabs() {
        let state = run([.push(.product(7)), .select(.search), .push(.category("bags")), .select(.home)])
        #expect(state.selectedTab == .home)
        #expect(state.paths[.home] == [.product(7)])
        #expect(state.paths[.search] == [.category("bags")])
    }

    @Test("Tapping the selected tab again pops it to its root")
    func reselect() {
        let state = run([.select(.search), .push(.category("bags")), .push(.product(9)), .select(.search)])
        #expect(state.selectedTab == .search)
        #expect(state.paths[.search] == [])
    }

    // MARK: - Sheets

    @Test("One sheet at a time")
    func oneSheet() {
        let state = run([.present(.share(productID: 7)), .present(.signIn)])
        #expect(state.sheet == .share(productID: 7))
        #expect(run([.present(.share(productID: 7)), .dismiss]).sheet == nil)
    }

    @Test("Tab actions are ignored while a sheet covers the tabs")
    func ignoredUnderSheet() {
        let start = run([.push(.product(7)), .present(.share(productID: 7))])
        for action in [Action.push(.reviews(productID: 7)), .pop, .popToRoot, .replace([.orders]), .select(.basket), .select(.home)] {
            #expect(run([action], from: start) == start)
        }
    }

    // MARK: - Deep links

    @Test("A link selects its tab and replaces that tab's path, leaving the others alone")
    func openLink() {
        let start = run([.push(.product(7)), .select(.search), .push(.category("bags"))])
        let state = run([.open(DeepLink(tab: .home, screens: [.category("shoes"), .product(42)]))], from: start)
        #expect(state.selectedTab == .home)
        #expect(state.paths[.home] == [.category("shoes"), .product(42)])
        #expect(state.paths[.search] == [.category("bags")])
    }

    @Test("A link dismisses whatever sheet is up first")
    func linkDismisses() {
        let start = run([.present(.share(productID: 7))])
        let state = run([.open(DeepLink(tab: .basket))], from: start)
        #expect(state == State(selectedTab: .basket))
    }

    @Test("A link to the account waits for sign-in and changes nothing else")
    func accountLinkSignedOut() {
        let start = run([.push(.product(7)), .present(.share(productID: 7))])
        let link = DeepLink(tab: .account, screens: [.orders, .order("A1B2C3")])
        let state = run([.open(link)], from: start)
        #expect(state.pendingLink == link)
        #expect(state.sheet == .signIn)
        #expect(state.selectedTab == .home)
        #expect(state.paths == start.paths)
    }

    @Test("Signing in opens the waiting link")
    func signInOpensPending() {
        let link = DeepLink(tab: .account, screens: [.orders, .order("A1B2C3")])
        let state = run([.push(.product(7)), .open(link), .signedIn])
        #expect(state == State(selectedTab: .account, paths: [.home: [.product(7)], .account: [.orders, .order("A1B2C3")]], isSignedIn: true))
    }

    @Test("Signed in, an account link opens at once")
    func accountLinkSignedIn() {
        let start = State(isSignedIn: true)
        let state = run([.open(DeepLink(tab: .account, screens: [.settings]))], from: start)
        #expect(state == State(selectedTab: .account, paths: [.account: [.settings]], isSignedIn: true))
    }

    @Test("Dismissing sign-in drops the waiting link")
    func cancelSignIn() {
        let link = DeepLink(tab: .account, screens: [.orders])
        let state = run([.open(link), .dismiss, .signedIn])
        #expect(state.pendingLink == nil)
        #expect(state.selectedTab == .home)
        #expect(state.paths[.account] == [])
        #expect(state.isSignedIn)
    }

    @Test("The newest link wins while sign-in is up")
    func newestLinkWins() {
        let orders = DeepLink(tab: .account, screens: [.orders])
        let order = DeepLink(tab: .account, screens: [.orders, .order("Z9Y8X7")])
        #expect(run([.open(orders), .open(order), .signedIn]).paths[.account] == [.orders, .order("Z9Y8X7")])

        // A link that needs no sign-in replaces the wait altogether
        let product = DeepLink(tab: .home, screens: [.product(42)])
        let state = run([.open(orders), .open(product)])
        #expect(state == State(paths: [.home: [.product(42)]]))
        #expect(run([.signedIn], from: state).selectedTab == .home)
    }

    @Test("Signing out empties the account tab and forgets any waiting link")
    func signOut() {
        let signedIn = run([.push(.product(7)), .open(DeepLink(tab: .account, screens: [.orders, .order("A1B2C3")]))], from: State(isSignedIn: true))
        let state = run([.signedOut], from: signedIn)
        #expect(state.isSignedIn == false)
        #expect(state.paths[.account] == [])
        #expect(state.paths[.home] == [.product(7)])
        #expect(state.selectedTab == .account)
    }

    @Test("A whole session, start to finish")
    func session() {
        let state = run([
            .push(.category("shoes")),
            .push(.product(7)),
            .present(.share(productID: 7)),
            .push(.reviews(productID: 7)),   // ignored: the share sheet is up
            .open(DeepLink(tab: .account, screens: [.orders, .order("A1B2C3")])),
            .signedIn,
            .pop,
            .select(.home),
            .push(.reviews(productID: 7)),
        ])
        #expect(state == State(
            selectedTab: .home,
            paths: [.home: [.category("shoes"), .product(7), .reviews(productID: 7)], .account: [.orders]],
            isSignedIn: true
        ))
    }
}
