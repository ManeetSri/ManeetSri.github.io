// Reference solution: An expense that always adds up. The root checks a proposed total and split as a
// pair before touching anything, so every change is all or nothing, and the shares are derived from the
// split rather than stored beside it, so they can't drift out of step.
import Foundation

public enum ModellingSplitExpense {
    public struct MemberID: Hashable, Comparable, Sendable, CustomStringConvertible {
        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public static func < (lhs: MemberID, rhs: MemberID) -> Bool { lhs.rawValue < rhs.rawValue }
        public var description: String { rawValue }
    }

    public enum Split: Equatable, Sendable {
        case equally(Set<MemberID>)
        case exactly([MemberID: Int])
    }

    public enum Problem: Error, Equatable, Sendable {
        case totalNotPositive
        case noParticipants
        case negativeShare(MemberID)
        case sharesDontAddUp(expected: Int, actual: Int)
        case notAParticipant(MemberID)
        case lastParticipant
    }

    public struct Expense: Identifiable, Equatable, Sendable {
        public let id: UUID
        public let paidBy: MemberID
        public private(set) var total: Int
        public private(set) var split: Split

        public init(id: UUID, paidBy: MemberID, total: Int, split: Split) throws {
            try Self.check(total: total, split: split)
            self.id = id
            self.paidBy = paidBy
            self.total = total
            self.split = split
        }

        /// The invariant, in one place: every way in goes through it before anything changes
        private static func check(total: Int, split: Split) throws {
            guard total >= 1 else { throw Problem.totalNotPositive }
            switch split {
            case let .equally(members):
                guard !members.isEmpty else { throw Problem.noParticipants }
            case let .exactly(amounts):
                guard !amounts.isEmpty else { throw Problem.noParticipants }
                if let negative = amounts.filter({ $0.value < 0 }).keys.min() {
                    throw Problem.negativeShare(negative)
                }
                let sum = amounts.values.reduce(0, +)
                guard sum == total else { throw Problem.sharesDontAddUp(expected: total, actual: sum) }
            }
        }

        public var shares: [MemberID: Int] {
            switch split {
            case let .equally(members):
                let ordered = members.sorted()
                let share = total / ordered.count
                let leftover = total % ordered.count
                return Dictionary(uniqueKeysWithValues: ordered.enumerated().map { index, member in
                    (member, share + (index < leftover ? 1 : 0))
                })
            case let .exactly(amounts):
                return amounts
            }
        }

        public var balances: [MemberID: Int] {
            var balances = shares
            balances[paidBy, default: 0] -= total
            return balances
        }

        public mutating func change(total: Int, split: Split) throws {
            try Self.check(total: total, split: split)
            self.total = total
            self.split = split
        }

        public mutating func changeTotal(to total: Int) throws {
            // An exact split's shares still add up to the old total, so the check refuses it
            try change(total: total, split: split)
        }

        public mutating func remove(_ member: MemberID) throws {
            let remaining: Split
            switch split {
            case var .equally(members):
                guard members.remove(member) != nil else { throw Problem.notAParticipant(member) }
                guard !members.isEmpty else { throw Problem.lastParticipant }
                remaining = .equally(members)
            case var .exactly(amounts):
                guard amounts.removeValue(forKey: member) != nil else { throw Problem.notAParticipant(member) }
                guard !amounts.isEmpty else { throw Problem.lastParticipant }
                remaining = .exactly(amounts)
            }
            // Equal: the others share the total. Exact: nobody covers the removed share, so the check refuses it.
            try change(total: total, split: remaining)
        }
    }
}
