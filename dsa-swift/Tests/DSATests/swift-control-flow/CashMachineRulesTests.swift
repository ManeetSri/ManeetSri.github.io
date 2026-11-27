import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct CashMachineRulesTests {
    static let aboveZero = "Enter an amount above zero"
    static let inTens = "Amounts must be in tens"
    static let overLimit = "Over the daily limit"
    static let notEnough = "Not enough money"

    @Test("Pays out when every rule passes", arguments: [
        (60, 140, 100, "Paid out 60. Balance: 80"),
        (10, 10, 500, "Paid out 10. Balance: 0"),
        (500, 1_000_000_000, 1_000_000, "Paid out 500. Balance: 999999500"),
    ])
    func paysOut(amount: Int, balance: Int, dailyLimit: Int, expected: String) {
        #expect(CashMachineRules.withdraw(amount: amount, balance: balance, dailyLimit: dailyLimit) == expected)
    }

    @Test("Reports each rule that fails on its own", arguments: [
        (0, 140, 100, "Enter an amount above zero"),
        (25, 140, 100, "Amounts must be in tens"),
        (110, 140, 100, "Over the daily limit"),
        (100, 90, 200, "Not enough money"),
    ])
    func eachRule(amount: Int, balance: Int, dailyLimit: Int, expected: String) {
        #expect(CashMachineRules.withdraw(amount: amount, balance: balance, dailyLimit: dailyLimit) == expected)
    }

    @Test("Checks the rules in order and reports the first failure")
    func order() {
        // Negative and a multiple of 10: rule 1 wins.
        #expect(CashMachineRules.withdraw(amount: -20, balance: 140, dailyLimit: 100) == Self.aboveZero)
        // Not in tens, over the limit and over the balance: rule 2 wins.
        #expect(CashMachineRules.withdraw(amount: 555, balance: 140, dailyLimit: 100) == Self.inTens)
        // Over the limit and over the balance: rule 3 wins.
        #expect(CashMachineRules.withdraw(amount: 150, balance: 140, dailyLimit: 100) == Self.overLimit)
        // Negative and not in tens: rule 1 still wins.
        #expect(CashMachineRules.withdraw(amount: -5, balance: 140, dailyLimit: 100) == Self.aboveZero)
    }

    @Test("At most allows exactly the limit and exactly the balance")
    func boundaries() {
        #expect(CashMachineRules.withdraw(amount: 100, balance: 100, dailyLimit: 100) == "Paid out 100. Balance: 0")
        #expect(CashMachineRules.withdraw(amount: 100, balance: 500, dailyLimit: 90) == Self.overLimit)
        #expect(CashMachineRules.withdraw(amount: 100, balance: 99, dailyLimit: 100) == Self.notEnough)
    }

    @Test("A zero limit or an empty account refuses any withdrawal")
    func zeroes() {
        #expect(CashMachineRules.withdraw(amount: 10, balance: 500, dailyLimit: 0) == Self.overLimit)
        #expect(CashMachineRules.withdraw(amount: 10, balance: 0, dailyLimit: 500) == Self.notEnough)
    }

    @Test("Handles the extremes of the allowed inputs")
    func extremes() {
        #expect(CashMachineRules.withdraw(amount: -1_000_000, balance: 0, dailyLimit: 0) == Self.aboveZero)
        #expect(CashMachineRules.withdraw(amount: 1_000_000, balance: 1_000_000, dailyLimit: 1_000_000) == "Paid out 1000000. Balance: 0")
    }
}
