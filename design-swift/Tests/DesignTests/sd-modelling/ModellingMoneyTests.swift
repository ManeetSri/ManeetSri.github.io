import DesignKit
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ModellingMoneyTests {
    typealias Money = ModellingMoney.Money
    typealias Currency = ModellingMoney.Currency
    typealias Problem = ModellingMoney.Problem

    private func pounds(_ text: String) throws -> Money {
        try Money(text, currency: .gbp)
    }

    @Test("Supported currencies are found by code, ignoring case and whitespace")
    func findsCurrencies() throws {
        #expect(try Currency(code: "GBP") == .gbp)
        #expect(try Currency(code: " gbp ") == .gbp)
        #expect(try Currency(code: "Jpy").minorUnitDigits == 0)
        #expect(try Currency(code: "kwd\n").minorUnitDigits == 3)
    }

    @Test("Unknown currency codes are refused, reporting the code as given", arguments: ["XYZ", "", "GBPX", " usd dollars"])
    func refusesUnknownCurrencies(code: String) {
        #expect(throws: Problem.unknownCurrency(code)) { try Currency(code: code) }
    }

    @Test("Parses amounts into minor units", arguments: [
        ("12.50", Currency.gbp, 1250),
        ("12.5", Currency.gbp, 1250),
        ("12", Currency.gbp, 1200),
        ("0.07", Currency.gbp, 7),
        (" 3.10 ", Currency.gbp, 310),
        ("-3.10", Currency.gbp, -310),
        ("007.00", Currency.eur, 700),
        ("1200", Currency.jpy, 1200),
        ("1.25", Currency.kwd, 1250),
        ("0.001", Currency.kwd, 1),
    ])
    func parsesAmounts(text: String, currency: Currency, minorUnits: Int) throws {
        #expect(try Money(text, currency: currency) == Money(minorUnits: minorUnits, currency: currency))
    }

    @Test("Refuses text that isn't a plain amount", arguments: ["", "abc", "1,000", "12.", ".5", "1.2.3", "+5", "- 5", "12 50", "£12", "-", "١٢"])
    func refusesNonAmounts(text: String) {
        #expect(throws: Problem.notAnAmount(text)) { try pounds(text) }
    }

    @Test("Refuses more decimal places than the currency has")
    func refusesTooPrecise() {
        #expect(throws: Problem.tooPrecise("12.345")) { try pounds("12.345") }
        #expect(throws: Problem.tooPrecise("1200.5")) { try Money("1200.5", currency: .jpy) }
        #expect(throws: Problem.tooPrecise("1.2345")) { try Money("1.2345", currency: .kwd) }
    }

    @Test("Refuses amounts too large to hold")
    func refusesOutOfRange() throws {
        #expect(throws: Problem.outOfRange("99999999999999999999")) { try pounds("99999999999999999999") }
        #expect(throws: Problem.outOfRange("92233720368547758.08")) { try pounds("92233720368547758.08") }
        #expect(try pounds("92233720368547758.07").minorUnits == Int.max)
    }

    @Test("Adds and subtracts amounts in one currency")
    func arithmetic() throws {
        let price = try pounds("12.50")
        let fee = try pounds("0.75")
        #expect(try price.adding(fee) == Money(minorUnits: 1325, currency: .gbp))
        #expect(try price.subtracting(fee) == Money(minorUnits: 1175, currency: .gbp))
        #expect(try fee.subtracting(price) == Money(minorUnits: -1175, currency: .gbp))
        #expect(try Money.zero(in: .gbp).adding(price) == price)
    }

    @Test("Refuses to mix currencies")
    func refusesMixedCurrencies() throws {
        let pound = try pounds("1")
        let dollar = try Money("1", currency: .usd)
        #expect(throws: Problem.currencyMismatch(.gbp, .usd)) { try pound.adding(dollar) }
        #expect(throws: Problem.currencyMismatch(.usd, .gbp)) { try dollar.subtracting(pound) }
    }

    @Test("Multiplies by a quantity")
    func multiplies() throws {
        #expect(try pounds("2.99").multiplied(by: 3) == Money(minorUnits: 897, currency: .gbp))
        #expect(try pounds("2.99").multiplied(by: 0) == .zero(in: .gbp))
        #expect(try pounds("2.99").multiplied(by: -2) == Money(minorUnits: -598, currency: .gbp))
    }

    @Test("Allocates without losing or inventing a single minor unit")
    func allocates() throws {
        let ten = try pounds("10")
        #expect(ten.allocated(into: 3).map(\.minorUnits) == [334, 333, 333])
        #expect(ten.allocated(into: 1) == [ten])
        #expect(try pounds("-10").allocated(into: 3).map(\.minorUnits) == [-334, -333, -333])
        #expect(try pounds("0.02").allocated(into: 3).map(\.minorUnits) == [1, 1, 0])
        #expect(try Money("100", currency: .jpy).allocated(into: 3) == [34, 33, 33].map { Money(minorUnits: $0, currency: .jpy) })
        #expect(ten.allocated(into: 0).isEmpty)
        #expect(ten.allocated(into: -2).isEmpty)

        for total in [1, 99, 1000, 1001, -7] {
            for parts in 1...7 {
                let shares = Money(minorUnits: total, currency: .gbp).allocated(into: parts)
                #expect(shares.count == parts)
                #expect(shares.map(\.minorUnits).reduce(0, +) == total)
                #expect(shares.allSatisfy { $0.currency == .gbp })
                #expect((shares.map(\.minorUnits).max() ?? 0) - (shares.map(\.minorUnits).min() ?? 0) <= 1)
            }
        }
    }

    @Test("Describes itself with the currency's decimal places")
    func describes() throws {
        #expect(try pounds("12.5").description == "GBP 12.50")
        #expect(try pounds("0.07").description == "GBP 0.07")
        #expect(try pounds("-0.05").description == "GBP -0.05")
        #expect(try Money("1200", currency: .jpy).description == "JPY 1200")
        #expect(try Money("1.25", currency: .kwd).description == "KWD 1.250")
        #expect(Money(minorUnits: -310, currency: .eur).description == "EUR -3.10")
    }
}
