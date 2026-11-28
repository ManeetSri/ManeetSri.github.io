// Generated from src/dsa/design/content/lessons/sd-di/sd-di-service-locator.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

protocol PriceFormatting {
    func format(pence: Int) -> String
}

struct PoundFormatter: PriceFormatting {
    func format(pence: Int) -> String { "£\(pence / 100)" }
}

struct EuroFormatter: PriceFormatting {
    func format(pence: Int) -> String { "€\(pence / 100)" }
}

@MainActor final class Locator {
    static let shared = Locator()
    private var services: [ObjectIdentifier: Any] = [:]

    func register<T>(_ service: T, as type: T.Type) {
        services[ObjectIdentifier(type)] = service
    }

    func resolve<T>(_ type: T.Type) -> T? {
        services[ObjectIdentifier(type)] as? T
    }
}

/// Resolves once, when it's created
@MainActor final class BasketRow {
    private let formatter = Locator.shared.resolve((any PriceFormatting).self)
    func label(pence: Int) -> String { formatter?.format(pence: pence) ?? "?" }
}

/// Resolves on every call
@MainActor final class TotalBar {
    func label(pence: Int) -> String { Locator.shared.resolve((any PriceFormatting).self)?.format(pence: pence) ?? "?" }
}

/// Injected: the root decides, and rebuilds the screen when the store changes
@MainActor final class CheckoutSummary {
    private let formatter: any PriceFormatting
    init(formatter: any PriceFormatting) { self.formatter = formatter }
    func label(pence: Int) -> String { formatter.format(pence: pence) }
}

Locator.shared.register(PoundFormatter(), as: (any PriceFormatting).self)
let row = BasketRow()
let total = TotalBar()
var summary = CheckoutSummary(formatter: PoundFormatter())
print("row:", row.label(pence: 1200), "· total:", total.label(pence: 1200), "· summary:", summary.label(pence: 1200))

// The user switches to the Irish store
Locator.shared.register(EuroFormatter(), as: (any PriceFormatting).self)
summary = CheckoutSummary(formatter: EuroFormatter())
print("row:", row.label(pence: 1200), "· total:", total.label(pence: 1200), "· summary:", summary.label(pence: 1200))
