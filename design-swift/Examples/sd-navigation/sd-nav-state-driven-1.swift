// Generated from src/dsa/design/content/lessons/sd-navigation/sd-nav-state-driven.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

enum Tab: String {
    case shop, basket, account
}

enum CheckoutStep: String {
    case address, delivery, payment
}

/// The checkout sheet's own navigation: steps pushed above the address step, and an optional alert
struct CheckoutNavigation: Equatable {
    var steps: [CheckoutStep] = []
    var alert: String?
}

/// At most one sheet, and each case carries the state of what it shows
enum Sheet: Equatable {
    case editQuantity(itemID: Int)
    case checkout(CheckoutNavigation)
}

/// The whole window's navigation, as one value
struct AppNavigation: Equatable, CustomStringConvertible {
    var tab = Tab.shop
    var sheet: Sheet?

    var description: String {
        var text = tab.rawValue
        switch sheet {
        case nil: break
        case .editQuantity(let id): text += ", sheet: quantity of \(id)"
        case .checkout(let checkout):
            let steps = [CheckoutStep.address] + checkout.steps
            text += ", sheet: checkout [\(steps.map(\.rawValue).joined(separator: ", "))]"
            if let alert = checkout.alert { text += ", alert: \(alert)" }
        }
        return text
    }
}

enum CheckoutAction {
    case next(CheckoutStep)
    case back
    case declined(String)
}

enum Action {
    case select(Tab)
    case present(Sheet)
    case dismiss
    case checkout(CheckoutAction)
}

func reduce(_ navigation: inout AppNavigation, _ action: Action) {
    switch action {
    case .select(let tab):
        navigation.tab = tab
    case .present(let sheet):
        guard navigation.sheet == nil else { return }   // one sheet at a time
        navigation.sheet = sheet
    case .dismiss:
        navigation.sheet = nil                          // and everything inside it, at once
    case .checkout(let action):
        // A late action from a checkout that's no longer showing changes nothing
        guard case .checkout(var checkout) = navigation.sheet else { return }
        switch action {
        case .next(let step): checkout.steps.append(step)
        case .back: _ = checkout.steps.popLast()
        case .declined(let reason): checkout.alert = reason
        }
        navigation.sheet = .checkout(checkout)
    }
}

var navigation = AppNavigation()
let actions: [(String, Action)] = [
    ("select basket", .select(.basket)),
    ("present checkout", .present(.checkout(CheckoutNavigation()))),
    ("next delivery", .checkout(.next(.delivery))),
    ("present quantity", .present(.editQuantity(itemID: 3))),
    ("next payment", .checkout(.next(.payment))),
    ("card declined", .checkout(.declined("card declined"))),
    ("dismiss", .dismiss),
    ("late next", .checkout(.next(.payment))),
]
for (label, action) in actions {
    reduce(&navigation, action)
    print("\(label):", navigation)
}

// A deep link to the payment step builds the nested value directly: no taps to replay
let link = AppNavigation(tab: .basket, sheet: .checkout(CheckoutNavigation(steps: [.delivery, .payment])))
print("deep link:", link)
