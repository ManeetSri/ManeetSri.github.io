import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@MainActor
@Suite struct NavigationCoordinatorTreeTests {
    typealias Coordinator = NavigationCoordinatorTree.Coordinator
    typealias Stack = NavigationCoordinatorTree.Stack
    typealias Outcome = NavigationCoordinatorTree.Outcome

    /// Something to capture in a closure, so a test can see whether the closure was released
    final class Token {}

    /// Records how each flow ended, in order
    @MainActor
    final class Log {
        var events: [String] = []

        func recorder(for name: String) -> @MainActor (Outcome) -> Void {
            { [self] outcome in
                switch outcome {
                case .completed(let result): events.append("\(name): completed \(result)")
                case .cancelled: events.append("\(name): cancelled")
                }
            }
        }
    }

    // MARK: - Starting and finishing

    @Test("Starting a child keeps it under its parent")
    func startChild() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        let checkout = Coordinator(name: "checkout", stack: stack)
        let log = Log()
        root.start(checkout, onFinish: log.recorder(for: "checkout"))
        #expect(root.children.map(\.name) == ["checkout"])
        #expect(checkout.parent === root)
        #expect(log.events.isEmpty)
    }

    @Test("A flow's screens go onto the stack and are remembered as its own")
    func show() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        let checkout = Coordinator(name: "checkout", stack: stack)
        root.show("basket")
        root.start(checkout) { _ in }
        checkout.show("address")
        checkout.show("payment")
        #expect(stack.screens == ["home", "basket", "address", "payment"])
        #expect(root.screens == ["basket"])
        #expect(checkout.screens == ["address", "payment"])
    }

    @Test("Finishing reports once, and the parent no longer holds the child")
    func finishOnce() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        let checkout = Coordinator(name: "checkout", stack: stack)
        let log = Log()
        root.start(checkout, onFinish: log.recorder(for: "checkout"))
        checkout.finish(.completed("A1B2C3"))
        checkout.finish(.cancelled)
        #expect(log.events == ["checkout: completed A1B2C3"])
        #expect(checkout.isFinished)
        #expect(checkout.parent == nil)
        #expect(root.children.isEmpty)
    }

    @Test("By the time the parent hears, the child has already left it")
    func detachBeforeReporting() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        let checkout = Coordinator(name: "checkout", stack: stack)
        var childrenSeen: [[String]] = []
        root.start(checkout) { _ in childrenSeen.append(root.children.map(\.name)) }
        checkout.finish(.completed("A1B2C3"))
        #expect(childrenSeen == [[]])
    }

    @Test("A finished flow takes its screens with it")
    func finishPopsScreens() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        let checkout = Coordinator(name: "checkout", stack: stack)
        root.show("basket")
        root.start(checkout) { _ in }
        checkout.show("address")
        checkout.show("payment")
        checkout.finish(.completed("A1B2C3"))
        #expect(stack.screens == ["home", "basket"])
        #expect(root.screens == ["basket"])
        #expect(checkout.screens.isEmpty)
    }

    @Test("Finishing a flow finishes its children first, newest first")
    func childrenFirst() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "app", stack: stack)
        let checkout = Coordinator(name: "checkout", stack: stack)
        let address = Coordinator(name: "address", stack: stack)
        let giftWrap = Coordinator(name: "gift wrap", stack: stack)
        let log = Log()
        root.start(checkout, onFinish: log.recorder(for: "checkout"))
        checkout.start(address, onFinish: log.recorder(for: "address"))
        checkout.start(giftWrap, onFinish: log.recorder(for: "gift wrap"))
        checkout.finish(.completed("A1B2C3"))
        #expect(log.events == ["gift wrap: cancelled", "address: cancelled", "checkout: completed A1B2C3"])
        #expect(address.isFinished && giftWrap.isFinished)
        #expect(checkout.children.isEmpty)
    }

    @Test("Starts that make no sense are ignored")
    func ignoredStarts() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        let other = Coordinator(name: "account", stack: stack)
        let checkout = Coordinator(name: "checkout", stack: stack)
        root.start(checkout) { _ in }
        other.start(checkout) { _ in }   // already has a parent
        root.start(root) { _ in }        // itself
        #expect(other.children.isEmpty)
        #expect(checkout.parent === root)
        #expect(root.children.map(\.name) == ["checkout"])

        let late = Coordinator(name: "late", stack: stack)
        checkout.finish(.cancelled)
        checkout.start(late) { _ in }    // a finished flow starts nothing
        checkout.show("address")         // or shows anything
        #expect(late.parent == nil)
        #expect(stack.screens == ["home"])
    }

    // MARK: - The back button

    @Test("Going back past a flow's first screen cancels it")
    func backPastFlow() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        stack.delegate = root
        let checkout = Coordinator(name: "checkout", stack: stack)
        let log = Log()
        root.show("basket")
        root.start(checkout, onFinish: log.recorder(for: "checkout"))
        checkout.show("address")
        checkout.show("payment")
        stack.pop(toCount: 2)   // the long-press back menu, straight to the basket
        #expect(log.events == ["checkout: cancelled"])
        #expect(root.children.isEmpty)
        #expect(stack.screens == ["home", "basket"])
        #expect(root.screens == ["basket"])
    }

    @Test("Going back within a flow keeps it running")
    func backWithinFlow() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        stack.delegate = root
        let checkout = Coordinator(name: "checkout", stack: stack)
        let log = Log()
        root.show("basket")
        root.start(checkout, onFinish: log.recorder(for: "checkout"))
        checkout.show("address")
        checkout.show("payment")
        stack.userTappedBack()
        #expect(log.events.isEmpty)
        #expect(checkout.screens == ["address"])
        #expect(root.children.map(\.name) == ["checkout"])
        stack.userTappedBack()
        #expect(log.events == ["checkout: cancelled"])
    }

    @Test("A back swipe out of nested flows cancels the deepest first")
    func backOutOfNestedFlows() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        stack.delegate = root
        let checkout = Coordinator(name: "checkout", stack: stack)
        let giftWrap = Coordinator(name: "gift wrap", stack: stack)
        let log = Log()
        root.show("basket")
        root.start(checkout, onFinish: log.recorder(for: "checkout"))
        checkout.show("address")
        checkout.start(giftWrap, onFinish: log.recorder(for: "gift wrap"))
        giftWrap.show("paper")
        giftWrap.show("message")
        stack.pop(toCount: 2)
        #expect(log.events == ["gift wrap: cancelled", "checkout: cancelled"])
        #expect(root.children.isEmpty)
    }

    @Test("A flow that never pushed a screen isn't cancelled by pops")
    func flowWithoutScreens() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        stack.delegate = root
        let banner = Coordinator(name: "promo banner", stack: stack)
        let log = Log()
        root.show("basket")
        root.show("product")
        root.start(banner, onFinish: log.recorder(for: "promo banner"))
        stack.userTappedBack()
        #expect(log.events.isEmpty)
        #expect(root.children.map(\.name) == ["promo banner"])
    }

    // MARK: - Letting go

    @Test("A finished child is freed")
    func childFreed() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        weak var weakChild: Coordinator?
        do {
            let checkout = Coordinator(name: "checkout", stack: stack)
            weakChild = checkout
            root.start(checkout) { _ in }
        }
        #expect(weakChild != nil, "the parent must keep a running child alive")
        weakChild?.finish(.completed("A1B2C3"))
        #expect(weakChild == nil, "nothing may keep a finished child alive")
    }

    @Test("The finish closure is released once it has run")
    func closureReleased() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        let checkout = Coordinator(name: "checkout", stack: stack)
        weak var weakToken: Token?
        do {
            let token = Token()
            weakToken = token
            root.start(checkout) { _ in _ = token }
        }
        #expect(weakToken != nil)
        checkout.finish(.cancelled)
        #expect(weakToken == nil)
    }

    @Test("A child captured by its own finish closure is still freed")
    func selfCapturingClosure() {
        let stack = Stack(root: "home")
        let root = Coordinator(name: "basket", stack: stack)
        weak var weakChild: Coordinator?
        var names: [String] = []
        do {
            let checkout = Coordinator(name: "checkout", stack: stack)
            weakChild = checkout
            root.start(checkout) { _ in names.append(checkout.name) }
        }
        weakChild?.finish(.completed("A1B2C3"))
        #expect(names == ["checkout"])
        #expect(weakChild == nil)
    }

    @Test("Releasing the root frees the whole tree: no cycles")
    func noCycles() {
        let stack = Stack(root: "home")
        weak var weakRoot: Coordinator?
        weak var weakChild: Coordinator?
        weak var weakGrandchild: Coordinator?
        do {
            let root = Coordinator(name: "app", stack: stack)
            let checkout = Coordinator(name: "checkout", stack: stack)
            let giftWrap = Coordinator(name: "gift wrap", stack: stack)
            stack.delegate = root
            root.start(checkout) { _ in }
            checkout.start(giftWrap) { _ in }
            checkout.show("address")
            weakRoot = root
            weakChild = checkout
            weakGrandchild = giftWrap
            #expect(root.children.count == 1 && checkout.children.count == 1)
        }
        #expect(weakRoot == nil)
        #expect(weakChild == nil)
        #expect(weakGrandchild == nil)
        #expect(stack.delegate == nil)
    }
}
