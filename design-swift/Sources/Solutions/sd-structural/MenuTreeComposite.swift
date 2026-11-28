// Reference solution: A menu composite. Every operation has the same shape: handle the leaf, and for a
// submenu, apply the operation to each child and combine the results. Each walks the tree once: O(n).
public enum MenuTreeComposite {
    public struct Action: Equatable, Sendable {
        public let id: String
        public let title: String

        public init(id: String, title: String) {
            self.id = id
            self.title = title
        }
    }

    public enum Element: Equatable, Sendable {
        case action(Action)
        case menu(title: String, children: [Element])
    }
}

extension MenuTreeComposite.Element {
    public var actionCount: Int {
        switch self {
        case .action:
            return 1
        case .menu(_, let children):
            return children.reduce(0) { $0 + $1.actionCount }
        }
    }

    public func filtered(_ isIncluded: (MenuTreeComposite.Action) -> Bool) -> MenuTreeComposite.Element? {
        switch self {
        case .action(let action):
            return isIncluded(action) ? self : nil
        case .menu(let title, let children):
            let kept = children.compactMap { $0.filtered(isIncluded) }
            return kept.isEmpty ? nil : .menu(title: title, children: kept)
        }
    }

    public func titlePath(to id: String) -> [String]? {
        switch self {
        case .action(let action):
            return action.id == id ? [action.title] : nil
        case .menu(let title, let children):
            for child in children {
                if let path = child.titlePath(to: id) { return [title] + path }
            }
            return nil
        }
    }

    public var duplicateActionIDs: [String] {
        var counts: [String: Int] = [:]
        countIDs(into: &counts)
        return counts.filter { $0.value > 1 }.keys.sorted()
    }

    private func countIDs(into counts: inout [String: Int]) {
        switch self {
        case .action(let action):
            counts[action.id, default: 0] += 1
        case .menu(_, let children):
            children.forEach { $0.countIDs(into: &counts) }
        }
    }
}
