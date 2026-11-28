// Kata: A menu composite (D11 · Composite: view hierarchies and menus)
public enum MenuTreeComposite {
    /// One command in a menu: the leaf of the tree
    public struct Action: Equatable, Sendable {
        public let id: String
        public let title: String

        public init(id: String, title: String) {
            self.id = id
            self.title = title
        }
    }

    /// A menu item: an action, or a submenu holding more items. Code that walks the tree treats
    /// both the same way, which is the point of a composite.
    public enum Element: Equatable, Sendable {
        case action(Action)
        case menu(title: String, children: [Element])
    }
}

extension MenuTreeComposite.Element {
    /// How many actions the tree holds, at every depth
    public var actionCount: Int {
        // Write your solution here, then run:
        // swift test --filter MenuTreeCompositeTests
        0
    }

    /// The tree with only the actions `isIncluded` keeps, in their original order. A submenu left
    /// with no actions, at any depth, is removed; if nothing is left at all, the result is nil.
    public func filtered(_ isIncluded: (MenuTreeComposite.Action) -> Bool) -> MenuTreeComposite.Element? {
        nil
    }

    /// The titles from this element down to the action with `id`, ending with the action's own
    /// title, or nil if the tree has no such action
    public func titlePath(to id: String) -> [String]? {
        nil
    }

    /// Action ids that appear more than once in the tree, sorted, each listed once
    public var duplicateActionIDs: [String] {
        []
    }
}
