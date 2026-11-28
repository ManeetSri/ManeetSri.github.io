// Reference solution: A Money value object. Amounts are whole minor units, so arithmetic is exact;
// every way in (a currency code, a typed amount) is checked once, and every way out keeps the rules.
import Foundation

public enum ModellingMoney {
    public enum Problem: Error, Equatable, Sendable {
        case unknownCurrency(String)
        case notAnAmount(String)
        case tooPrecise(String)
        case outOfRange(String)
        case currencyMismatch(Currency, Currency)
    }

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

        public init(code: String) throws {
            let normalised = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            guard let match = Currency.supported.first(where: { $0.code == normalised }) else {
                throw Problem.unknownCurrency(code)
            }
            self = match
        }

        public var description: String { code }
    }

    public struct Money: Hashable, Sendable, CustomStringConvertible {
        public let minorUnits: Int
        public let currency: Currency

        public init(minorUnits: Int, currency: Currency) {
            self.minorUnits = minorUnits
            self.currency = currency
        }

        public init(_ text: String, currency: Currency) throws {
            var rest = Substring(text.trimmingCharacters(in: .whitespacesAndNewlines))
            let isNegative = rest.first == "-"
            if isNegative { rest = rest.dropFirst() }

            let pieces = rest.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
            let whole = pieces[0]
            let fraction = pieces.count == 2 ? pieces[1] : ""
            let isDigits = { (piece: Substring) in !piece.isEmpty && piece.allSatisfy { $0.isASCII && $0.isNumber } }
            guard isDigits(whole), pieces.count == 1 || isDigits(fraction) else { throw Problem.notAnAmount(text) }
            guard fraction.count <= currency.minorUnitDigits else { throw Problem.tooPrecise(text) }

            // "12.5" in pounds is 12 and 50 pence: pad the fraction to the currency's places, then read one integer
            let padded = fraction + String(repeating: "0", count: currency.minorUnitDigits - fraction.count)
            guard let magnitude = Int(whole + padded) else { throw Problem.outOfRange(text) }
            self.init(minorUnits: isNegative ? -magnitude : magnitude, currency: currency)
        }

        public static func zero(in currency: Currency) -> Money {
            Money(minorUnits: 0, currency: currency)
        }

        public func adding(_ other: Money) throws -> Money {
            try requireSameCurrency(as: other)
            return Money(minorUnits: minorUnits + other.minorUnits, currency: currency)
        }

        public func subtracting(_ other: Money) throws -> Money {
            try requireSameCurrency(as: other)
            return Money(minorUnits: minorUnits - other.minorUnits, currency: currency)
        }

        private func requireSameCurrency(as other: Money) throws {
            guard currency == other.currency else { throw Problem.currencyMismatch(currency, other.currency) }
        }

        public func multiplied(by quantity: Int) -> Money {
            Money(minorUnits: minorUnits * quantity, currency: currency)
        }

        public func allocated(into parts: Int) -> [Money] {
            guard parts >= 1 else { return [] }
            // Integer division truncates towards zero, and the remainder has the amount's sign, so the
            // leftover minor units go one each, in that direction, to the first parts
            let share = minorUnits / parts
            let leftover = minorUnits % parts
            let step = leftover < 0 ? -1 : 1
            return (0..<parts).map { index in
                Money(minorUnits: share + (index < abs(leftover) ? step : 0), currency: currency)
            }
        }

        public var description: String {
            let sign = minorUnits < 0 ? "-" : ""
            let magnitude = minorUnits.magnitude
            let places = currency.minorUnitDigits
            guard places > 0 else { return "\(currency.code) \(sign)\(magnitude)" }
            let divisor = (0..<places).reduce(UInt(1)) { result, _ in result * 10 }
            let fraction = String(magnitude % divisor)
            let paddedFraction = String(repeating: "0", count: places - fraction.count) + fraction
            return "\(currency.code) \(sign)\(magnitude / divisor).\(paddedFraction)"
        }
    }
}
