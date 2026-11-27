import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct FirstOverdraftDayTests {
    @Test("Finds the first overdrawn day", arguments: [
        (50, [-20, -20, 30, -70, 10], 3),
        (0, [5, -5, -1], 2),
        (0, [-1], 0),
        (10, [-11, 100], 0),
        (5, [1, 1, 1, -9], 3),
        (20, [-30, 50, -100], 0),
    ])
    func finds(balance: Int, changes: [Int], expected: Int) {
        #expect(FirstOverdraftDay.day(startingWith: balance, changes: changes) == expected)
    }

    @Test("Returns nil when the balance never drops below zero", arguments: [
        (100, [-10, 20, -50]),
        (10, [Int]()),
        (0, [Int]()),
        (0, [0, 0, 0]),
        (7, [-7, 3, -3]),
    ])
    func never(balance: Int, changes: [Int]) {
        #expect(FirstOverdraftDay.day(startingWith: balance, changes: changes) == nil)
    }

    @Test("A balance of exactly zero isn't overdrawn")
    func exactlyZero() {
        #expect(FirstOverdraftDay.day(startingWith: 30, changes: [-10, -20]) == nil)
        #expect(FirstOverdraftDay.day(startingWith: 30, changes: [-10, -20, -1]) == 2)
    }

    @Test("Money coming in later doesn't undo an overdraft")
    func laterDeposits() {
        #expect(FirstOverdraftDay.day(startingWith: 1, changes: [-2, 1_000, 1_000]) == 0)
    }

    @Test("Handles the largest amounts without overflowing")
    func largeAmounts() {
        let big = 1_000_000_000
        let deposits = Array(repeating: big, count: 100_000)
        #expect(FirstOverdraftDay.day(startingWith: big, changes: deposits) == nil)
        let withdrawals = Array(repeating: -big, count: 100_000)
        #expect(FirstOverdraftDay.day(startingWith: big, changes: withdrawals) == 1)
    }

    @Test("Stays fast on 100,000 days")
    func large() {
        var changes = Array(repeating: 1, count: 100_000)
        changes[99_999] = -200_000
        #expect(FirstOverdraftDay.day(startingWith: 0, changes: changes) == 99_999)
        changes[3] = -10
        #expect(FirstOverdraftDay.day(startingWith: 0, changes: changes) == 3)
    }
}
