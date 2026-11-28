// Reference solution: A coordinator tree that lets go. Ownership points down (children in an array,
// the parent weak); a finish runs once, children first, takes the flow's screens with it, detaches,
// then reports and drops the callback. System pops reach the root as the stack's delegate, which
// cancels, deepest first, every running flow whose screens are all gone.
import Foundation

public enum NavigationCoordinatorTree {
    public enum Outcome: Equatable, Sendable {
        case completed(String)
        case cancelled
    }

    @MainActor
    public protocol StackDelegate: AnyObject {
        func stack(_ stack: Stack, didRemove screens: [String])
    }

    @MainActor
    public final class Stack {
        public private(set) var screens: [String]
        public weak var delegate: (any StackDelegate)?

        public init(root: String) {
            screens = [root]
        }

        public func push(_ screen: String) {
            screens.append(screen)
        }

        public func pop(toCount count: Int) {
            let keep = max(1, min(count, screens.count))
            guard keep < screens.count else { return }
            let removed = Array(screens[keep...])
            screens.removeSubrange(keep...)
            delegate?.stack(self, didRemove: removed)
        }

        public func userTappedBack() {
            pop(toCount: screens.count - 1)
        }
    }

    @MainActor
    public final class Coordinator: StackDelegate {
        public let name: String
        public let stack: Stack
        public private(set) var children: [Coordinator] = []
        public private(set) weak var parent: Coordinator?
        public private(set) var screens: [String] = []
        public private(set) var isFinished = false

        private var onFinish: (@MainActor (Outcome) -> Void)?
        private var hasShownScreens = false

        public init(name: String, stack: Stack) {
            self.name = name
            self.stack = stack
        }

        public func show(_ screen: String) {
            guard !isFinished else { return }
            stack.push(screen)
            screens.append(screen)
            hasShownScreens = true
        }

        public func start(_ child: Coordinator, onFinish: @escaping @MainActor (Outcome) -> Void) {
            guard !isFinished, child !== self, child.parent == nil, !child.isFinished else { return }
            children.append(child)
            child.parent = self
            child.onFinish = onFinish
        }

        public func finish(_ outcome: Outcome) {
            guard !isFinished else { return }
            isFinished = true

            // Children first, newest first: a flow can't outlive the flow that started it
            for child in children.reversed() {
                child.finish(.cancelled)
            }

            // A finished flow takes its screens, and anything above them, off the stack
            if let first = screens.first, let index = stack.screens.firstIndex(of: first) {
                stack.pop(toCount: index)
            }
            screens = []

            // Detach before reporting, so the parent sees itself without this child
            parent?.children.removeAll { $0 === self }
            parent = nil

            // Report once, then drop the closure and everything it captured
            let report = onFinish
            onFinish = nil
            report?(outcome)
        }

        public func stack(_ stack: Stack, didRemove removed: [String]) {
            let tree = subtree()
            for coordinator in tree {
                coordinator.screens.removeAll { removed.contains($0) }
            }
            // Deepest first, so a grandchild is cancelled before the child that started it
            for coordinator in tree where !coordinator.isFinished && coordinator.hasShownScreens && coordinator.screens.isEmpty {
                coordinator.finish(.cancelled)
            }
        }

        /// This coordinator and all its descendants, children before parents
        private func subtree() -> [Coordinator] {
            children.flatMap { $0.subtree() } + [self]
        }
    }
}
