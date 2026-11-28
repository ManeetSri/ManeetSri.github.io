import DesignKit
import Foundation
import Testing
#if SOLUTIONS
import Solutions
#else
import Exercises
#endif

@Suite struct ModellingSplitExpenseTests {
    typealias Expense = ModellingSplitExpense.Expense
    typealias MemberID = ModellingSplitExpense.MemberID
    typealias Problem = ModellingSplitExpense.Problem

    let ana = MemberID("ana")
    let ben = MemberID("ben")
    let cy = MemberID("cy")
    let dan = MemberID("dan")
    let dinner = UUID(uuidString: "7D3F1C2A-9B4E-4F6A-8C1D-2E5B6A7C8D9E")!

    private func equal(_ total: Int, among members: Set<MemberID>, paidBy payer: MemberID? = nil) throws -> Expense {
        try Expense(id: dinner, paidBy: payer ?? ana, total: total, split: .equally(members))
    }

    @Test("An equal split shares the total, extra pennies to the lowest ids first")
    func equalSplit() throws {
        #expect(try equal(1000, among: [cy, ana, ben]).shares == [ana: 334, ben: 333, cy: 333])
        #expect(try equal(1001, among: [cy, ana, ben]).shares == [ana: 334, ben: 334, cy: 333])
        #expect(try equal(900, among: [ana, ben, cy]).shares == [ana: 300, ben: 300, cy: 300])
        #expect(try equal(1, among: [ben, ana]).shares == [ana: 1, ben: 0])
    }

    @Test("An exact split keeps the amounts it was given")
    func exactSplit() throws {
        let taxi = try Expense(id: dinner, paidBy: ben, total: 1000, split: .exactly([ana: 700, ben: 300]))
        #expect(taxi.shares == [ana: 700, ben: 300])
        #expect(taxi.total == 1000)
        #expect(taxi.paidBy == ben)
    }

    @Test("Creating an expense enforces every rule, reporting the first one broken")
    func creationRules() {
        #expect(throws: Problem.totalNotPositive) { try equal(0, among: [ana]) }
        #expect(throws: Problem.totalNotPositive) { try equal(-500, among: []) }
        #expect(throws: Problem.noParticipants) { try equal(1000, among: []) }
        #expect(throws: Problem.noParticipants) { try Expense(id: dinner, paidBy: ana, total: 1000, split: .exactly([:])) }
        #expect(throws: Problem.negativeShare(ben)) { try Expense(id: dinner, paidBy: ana, total: 1000, split: .exactly([ana: 1100, ben: -100])) }
        #expect(throws: Problem.negativeShare(ben)) { try Expense(id: dinner, paidBy: ana, total: 1000, split: .exactly([cy: -50, ana: 1100, ben: -50])) }
        #expect(throws: Problem.sharesDontAddUp(expected: 1000, actual: 900)) { try Expense(id: dinner, paidBy: ana, total: 1000, split: .exactly([ana: 600, ben: 300])) }
    }

    @Test("Shares always add up to the total")
    func sharesAddUp() throws {
        let everyone = [ana, ben, cy, dan, MemberID("eve"), MemberID("fin"), MemberID("gus")]
        for total in [1, 2, 7, 99, 100, 1001, 123_457] {
            for size in 1...everyone.count {
                let expense = try equal(total, among: Set(everyone.prefix(size)))
                #expect(expense.shares.count == size)
                #expect(expense.shares.values.reduce(0, +) == total)
                #expect(expense.shares.values.max()! - expense.shares.values.min()! <= 1)
            }
        }
    }

    @Test("Balances net to zero, whether or not the payer shares the cost")
    func balances() throws {
        let shared = try equal(1000, among: [ana, ben, cy], paidBy: ana)
        #expect(shared.balances == [ana: -666, ben: 333, cy: 333])
        #expect(shared.balances.values.reduce(0, +) == 0)

        let treat = try equal(1000, among: [ana, ben], paidBy: dan)
        #expect(treat.balances == [ana: 500, ben: 500, dan: -1000])

        let solo = try equal(450, among: [ana], paidBy: ana)
        #expect(solo.balances == [ana: 0])
    }

    @Test("Changing the total shares an equal split out again")
    func changeEqualTotal() throws {
        var expense = try equal(900, among: [ana, ben, cy])
        try expense.changeTotal(to: 1500)
        #expect(expense.total == 1500)
        #expect(expense.shares == [ana: 500, ben: 500, cy: 500])
    }

    @Test("An exact split can't change its total without saying who pays what")
    func changeExactTotal() throws {
        var expense = try Expense(id: dinner, paidBy: ana, total: 1000, split: .exactly([ana: 700, ben: 300]))
        let before = expense
        #expect(throws: Problem.sharesDontAddUp(expected: 1200, actual: 1000)) { try expense.changeTotal(to: 1200) }
        #expect(expense == before)

        try expense.change(total: 1200, split: .exactly([ana: 900, ben: 300]))
        #expect(expense.total == 1200)
        #expect(expense.shares == [ana: 900, ben: 300])

        try expense.change(total: 1200, split: .equally([ana, ben, cy]))
        #expect(expense.shares == [ana: 400, ben: 400, cy: 400])
    }

    @Test("A refused change leaves the expense exactly as it was")
    func refusedChangesAreAtomic() throws {
        var expense = try equal(900, among: [ana, ben, cy])
        let before = expense
        #expect(throws: Problem.totalNotPositive) { try expense.change(total: 0, split: .equally([ana])) }
        #expect(throws: Problem.noParticipants) { try expense.change(total: 1200, split: .equally([])) }
        #expect(throws: Problem.sharesDontAddUp(expected: 1200, actual: 1100)) { try expense.change(total: 1200, split: .exactly([ana: 1100])) }
        #expect(throws: Problem.totalNotPositive) { try expense.changeTotal(to: -1) }
        #expect(expense == before)
        #expect(expense.shares == [ana: 300, ben: 300, cy: 300])
    }

    @Test("Removing a participant from an equal split shares their part among the rest")
    func removeFromEqualSplit() throws {
        var expense = try equal(900, among: [ana, ben, cy])
        try expense.remove(cy)
        #expect(expense.split == .equally([ana, ben]))
        #expect(expense.shares == [ana: 450, ben: 450])

        let before = expense
        #expect(throws: Problem.notAParticipant(dan)) { try expense.remove(dan) }
        try expense.remove(ben)
        #expect(throws: Problem.lastParticipant) { try expense.remove(ana) }
        #expect(expense.shares == [ana: 900])
        #expect(before.shares == [ana: 450, ben: 450])
    }

    @Test("Removing someone from an exact split needs someone to cover their share")
    func removeFromExactSplit() throws {
        var expense = try Expense(id: dinner, paidBy: ana, total: 1000, split: .exactly([ana: 700, ben: 300, cy: 0]))
        let before = expense
        #expect(throws: Problem.sharesDontAddUp(expected: 1000, actual: 700)) { try expense.remove(ben) }
        #expect(throws: Problem.notAParticipant(dan)) { try expense.remove(dan) }
        #expect(expense == before)

        try expense.remove(cy)
        #expect(expense.shares == [ana: 700, ben: 300])
    }
}
