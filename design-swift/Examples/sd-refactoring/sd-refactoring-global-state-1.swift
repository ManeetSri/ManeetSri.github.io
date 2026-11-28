// Generated from src/dsa/design/content/lessons/sd-refactoring/sd-refactoring-global-state.mdx. Edit the lesson, then run
// `npm run design:examples` to update this file. Run it from design-swift/ with: swift <this file>

import Foundation

@MainActor final class Settings {
    static let shared = Settings()
    var currencyCode = "GBP"
}

// A hidden input: nothing in the signature says the result depends on Settings
@MainActor func priceLabel(pence: Int) -> String {
    let amount = Decimal(pence) / 100
    let style = Decimal.FormatStyle.Currency(code: Settings.shared.currencyCode, locale: Locale(identifier: "en_GB"))
    return amount.formatted(style)
}

// Two tests, run one after the other, as a test runner might
@MainActor func irishPricesUseEuros() -> Bool {
    Settings.shared.currencyCode = "EUR"
    return priceLabel(pence: 1250) == "€12.50"
}

@MainActor func britishPricesUsePounds() -> Bool {
    priceLabel(pence: 1250) == "£12.50"
}

print("British prices:", britishPricesUsePounds() ? "pass" : "fail")
print("Irish prices:", irishPricesUseEuros() ? "pass" : "fail")
print("British prices again:", britishPricesUsePounds() ? "pass" : "fail")
