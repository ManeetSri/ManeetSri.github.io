// Kata: An expense that always adds up (D02 · Aggregates and consistency boundaries)
import DesignKit
import Foundation

public enum ModellingSplitExpense {
    /// A member of the group, such as "ana". Ids sort alphabetically, which decides who gets leftover pennies.
    public struct MemberID: Hashable, Comparable, Sendable, CustomStringConvertible {
        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        public static func < (lhs: MemberID, rhs: MemberID) -> Bool { lhs.rawValue < rhs.rawValue }
        public var description: String { rawValue }
    }

    /// How an expense is shared
    public enum Split: Equatable, Sendable {
        /// The total shared as evenly as pennies allow. Leftover pennies go one each to the
        /// participants with the lowest ids.
        case equally(Set<MemberID>)
        /// Each participant's share, in pence, given exactly
        case exactly([MemberID: Int])
    }

    /// Why a change was refused. When creating or changing an expense breaks several rules, the first
    /// one in this list is reported.
    public enum Problem: Error, Equatable, Sendable {
        /// The total must be at least 1p
        case totalNotPositive
        /// A split needs at least one participant
        case noParticipants
        /// An exact share below zero (the lowest such id when there are several)
        case negativeShare(MemberID)
        /// Exact shares that don't add up to the total
        case sharesDontAddUp(expected: Int, actual: Int)
        /// Removing someone who isn't in the split
        case notAParticipant(MemberID)
        /// Removing the only participant
        case lastParticipant
    }

    /// One expense in a shared-expenses app: who paid, how much, and how it's shared. It's an aggregate:
    /// the total and the shares change together, through these methods only, so the shares always add
    /// up to the total. A change that's refused leaves the expense exactly as it was.
    public struct Expense: Identifiable, Equatable, Sendable {
        public let id: UUID
        /// Who paid. They needn't be one of the participants: you can pay for other people.
        public let paidBy: MemberID
        /// In pence
        public private(set) var total: Int
        public private(set) var split: Split

        public init(id: UUID, paidBy: MemberID, total: Int, split: Split) throws {
            // Write your solution here, then run:
            // swift test --filter ModellingSplitExpenseTests
            throw Unimplemented()
        }

        /// Each participant's share in pence. They always add up to `total`.
        public var shares: [MemberID: Int] {
            [:]
        }

        /// What each person owes the group (positive) or is owed (negative): every participant's share,
        /// less the total for the payer. The payer always appears; the balances always add up to zero.
        public var balances: [MemberID: Int] {
            [:]
        }

        /// Changes the total and the split together, checking them as `init` does.
        public mutating func change(total: Int, split: Split) throws {
            throw Unimplemented()
        }

        /// Changes the total and keeps the split, checking them as `init` does. An equal split shares the
        /// new total out again. An exact split's shares still add up to the old total, so a new total
        /// throws `sharesDontAddUp`: the caller must say who pays what, with `change(total:split:)`.
        public mutating func changeTotal(to total: Int) throws {
            throw Unimplemented()
        }

        /// Takes someone out of an equal split; the others share the total. Throws `notAParticipant` if
        /// they aren't in the split, then `lastParticipant` if they're the only one. An exact split then
        /// throws `sharesDontAddUp(expected: total, actual: total minus their share)`, because someone has
        /// to cover their share.
        public mutating func remove(_ member: MemberID) throws {
            throw Unimplemented()
        }
    }
}
