// Generated from src/dsa/design/content/lessons/sd-behavioural-1/sd-behavioural-observer.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

/// A subscription. Cancel it, or let go of it, to stop hearing about changes.
final class CartObservation {
    private var onCancel: (() -> Void)?

    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }

    func cancel() {
        onCancel?()
        onCancel = nil
    }

    deinit {
        cancel()
    }
}

final class CartStore {
    private(set) var items: [String] = []
    private var observers: [(id: Int, notify: ([String]) -> Void)] = []
    private var nextID = 0

    func observe(_ notify: @escaping ([String]) -> Void) -> CartObservation {
        let id = nextID
        nextID += 1
        observers.append((id, notify))
        return CartObservation { [weak self] in
            self?.observers.removeAll { $0.id == id }
        }
    }

    func add(_ item: String) {
        items.append(item)
        for observer in observers {
            observer.notify(items)
        }
    }
}

let cart = CartStore()
var tokens: [CartObservation] = []
tokens.append(cart.observe { items in print("Badge shows \(items.count)") })
tokens.append(cart.observe { items in print("Analytics: added \(items.last ?? "?")") })

cart.add("Coffee beans")
tokens.removeLast()
cart.add("Grinder")
tokens.removeAll()
cart.add("Filters")
print("Cart has \(cart.items.count) items, \(tokens.count) observers")
