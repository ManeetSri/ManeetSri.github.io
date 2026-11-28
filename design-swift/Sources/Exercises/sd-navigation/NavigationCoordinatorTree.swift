// Kata: A coordinator tree that lets go (D20 · Coordinators in UIKit, Coordinators in SwiftUI)
import Foundation

public enum NavigationCoordinatorTree {
    /// How a flow ended, as its parent hears it
    public enum Outcome: Equatable, Sendable {
        /// The flow did its job; the string is its result, such as an order id
        case completed(String)
        case cancelled
    }

    /// Told when screens leave a stack, as a navigation controller's delegate is
    @MainActor
    public protocol StackDelegate: AnyObject {
        func stack(_ stack: Stack, didRemove screens: [String])
    }

    /// Stands in for a UINavigationController: the screens on one stack, by name, bottom first.
    /// It's complete: you don't need to change it.
    @MainActor
    public final class Stack {
        public private(set) var screens: [String]
        /// Weak, like a navigation controller's delegate: whoever sets it must keep it alive
        public weak var delegate: (any StackDelegate)?

        /// A stack showing only its root screen, which nothing can pop
        public init(root: String) {
            screens = [root]
        }

        public func push(_ screen: String) {
            screens.append(screen)
        }

        /// Pops until `count` screens remain (never fewer than one), then tells the delegate what was
        /// removed. Pops your code asks for and pops the user makes are reported the same way.
        public func pop(toCount count: Int) {
            let keep = max(1, min(count, screens.count))
            guard keep < screens.count else { return }
            let removed = Array(screens[keep...])
            screens.removeSubrange(keep...)
            delegate?.stack(self, didRemove: removed)
        }

        /// What the back button and the edge swipe do: UIKit pops without asking your code
        public func userTappedBack() {
            pop(toCount: screens.count - 1)
        }
    }

    /// One flow. Parents keep their running children alive; nothing else does.
    @MainActor
    public final class Coordinator: StackDelegate {
        public let name: String
        public let stack: Stack
        /// The child flows running under this one, oldest first
        public private(set) var children: [Coordinator] = []
        /// The flow that started this one. Weak: a child must never keep its parent alive.
        public private(set) weak var parent: Coordinator?
        /// The screens this flow pushed that are still on the stack, bottom first
        public private(set) var screens: [String] = []
        public private(set) var isFinished = false

        public init(name: String, stack: Stack) {
            self.name = name
            self.stack = stack
        }

        /// Pushes `screen` onto the stack as one of this flow's screens
        public func show(_ screen: String) {
            // Write your solution here, then run:
            // swift test --filter NavigationCoordinatorTreeTests
        }

        /// Starts `child` under this flow. `onFinish` runs once, when the child finishes.
        public func start(_ child: Coordinator, onFinish: @escaping @MainActor (Outcome) -> Void) {
        }

        /// Ends this flow: its children first, then its screens, then it leaves its parent and reports
        public func finish(_ outcome: Outcome) {
        }

        /// The stack's delegate (the app sets it to the root flow): screens have left the stack
        public func stack(_ stack: Stack, didRemove screens: [String]) {
        }
    }
}
