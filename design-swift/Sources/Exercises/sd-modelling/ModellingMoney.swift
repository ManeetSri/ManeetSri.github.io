// Kata: A Money value object (D02 · From primitive obsession to domain types)
import DesignKit
import Foundation

public enum ModellingMoney {
    /// Why a currency or an amount was refused
    public enum Problem: Error, Equatable, Sendable {
        /// A currency code this app doesn't support. Carries the code as it was given.
        case unknownCurrency(String)
        /// Text that isn't a plain decimal amount, such as "", "abc", "1,000", ".5" or "12.". Carries the text as given.
        case notAnAmount(String)
        /// More decimal places than the currency has, such as "12.345" in pounds. Carries the text as given.
        case tooPrecise(String)
        /// An amount too large to hold in minor units. Carries the text as given.
        case outOfRange(String)
        /// Arithmetic on two different currencies: the receiver's first, then the argument's
        case currencyMismatch(Currency, Currency)
    }

    /// A currency and how many decimal places its amounts have (ISO 4217's minor units).
    /// The only currencies are the ones below: you can't make up your own.
    public struct Currency: Hashable, Sendable, CustomStringConvertible {
        public let code: String
        public let minorUnitDigits: Int

        private init(code: String, minorUnitDigits: Int) {
            self.code = code
            self.minorUnitDigits = minorUnitDigits
        }

        public static let gbp = Currency(code: "GBP", minorUnitDigits: 2)
        public static let eur = Currency(code: "EUR", minorUnitDigits: 2)
        public static let usd = Currency(code: "USD", minorUnitDigits: 2)
        public static let jpy = Currency(code: "JPY", minorUnitDigits: 0)
        public static let kwd = Currency(code: "KWD", minorUnitDigits: 3)
        public static let supported: [Currency] = [.gbp, .eur, .usd, .jpy, .kwd]

        /// Finds a supported currency by its code, ignoring case and surrounding whitespace.
        /// Throws `Problem.unknownCurrency` with the code as given.
        public init(code: String) throws {
            // Write your solution here, then run:
            // swift test --filter ModellingMoneyTests
            throw Unimplemented()
        }

        public var description: String { code }
    }

    /// An amount of money: a whole number of the currency's minor units (pence, cents, yen, fils).
    public struct Money: Hashable, Sendable, CustomStringConvertible {
        public let minorUnits: Int
        public let currency: Currency

        public init(minorUnits: Int, currency: Currency) {
            self.minorUnits = minorUnits
            self.currency = currency
        }

        /// Parses a plain decimal amount, such as "12.50", "12.5", "12", "-3.10" or " 0.07 ".
        /// Surrounding whitespace is ignored; an optional leading "-" is allowed; then one or more digits,
        /// optionally followed by "." and one or more digits, but no more of them than the currency has.
        public init(_ text: String, currency: Currency) throws {
            throw Unimplemented()
        }

        public static func zero(in currency: Currency) -> Money {
            Money(minorUnits: 0, currency: currency)
        }

        /// Throws `Problem.currencyMismatch` unless both amounts are in the same currency.
        public func adding(_ other: Money) throws -> Money {
            throw Unimplemented()
        }

        /// Throws `Problem.currencyMismatch` unless both amounts are in the same currency.
        public func subtracting(_ other: Money) throws -> Money {
            throw Unimplemented()
        }

        public func multiplied(by quantity: Int) -> Money {
            self
        }

        /// Splits the amount into `parts` amounts that differ by at most one minor unit, larger ones
        /// first, and add up exactly to this amount. No parts (an empty array) when `parts` is below 1.
        public func allocated(into parts: Int) -> [Money] {
            []
        }

        /// The code, a space, then the amount with exactly the currency's decimal places:
        /// "GBP 12.50", "JPY 1200", "KWD 1.250", "GBP -0.05".
        public var description: String {
            ""
        }
    }
}
